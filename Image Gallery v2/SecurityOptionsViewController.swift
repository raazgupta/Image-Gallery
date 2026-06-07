//
//  SecurityOptionsViewController.swift
//  Image Gallery v2
//
//  Created by Raj Gupta on 2020/08/26.
//  Copyright © 2020 SoulfulMachine. All rights reserved.
//

import UIKit
import OSLog

protocol SecurityOptionsViewControllerDelegate: NSObjectProtocol {
    func doSomethingWith(
        pwSwitch: Bool,
        pw: String,
        isEN: Bool,
        isPWEN: Bool,
        star1Probability: Float,
        star2Probability: Float,
        star3Probability: Float,
        gachaAnimationStyle: ImageGalleryModel.GachaAnimationStyle
    )
}

class SecurityOptionsViewController: UIViewController, UITextFieldDelegate {
    private let premiumStore = PremiumAnimationsStore.shared
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "ImageKeeper", category: "SecurityOptions")
    private var premiumUnlocked = false
    private var statusResetTask: DispatchWorkItem?
    private var purchaseInFlight = false
    private var purchaseRoundTrippedThroughAppStore = false

    private func debugPrint(_ message: String) {
        print("[SecurityOptions] \(message)")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    weak var delegate: SecurityOptionsViewControllerDelegate?
    
    var star1Probability: Float = 60.0
    var star2Probability: Float = 30.0
    var star3Probability: Float = 10.0
    var galleryPW: String = ""
    var galleryEN: Bool = false
    var galleryPWEN: Bool = false
    var gachaAnimationStyle: ImageGalleryModel.GachaAnimationStyle = .mysteryCard
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyButton.layer.cornerRadius = 10.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        passwordText.delegate = self
        star1Text.delegate = self
        star2Text.delegate = self
        star3Text.delegate = self
        
        star1Text.text = String(star1Probability)
        star2Text.text = String(star2Probability)
        star3Text.text = String(star3Probability)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard(_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        encryptFile.isOn = galleryEN
        encryptPassword.isOn = galleryPWEN
        
        if galleryPW != "" {
            setPassword.isOn = true
            passwordText.isHidden = false
            passwordText.text = galleryPW
        }

        premiumUnlocked = premiumStore.isPremiumUnlocked
        if gachaAnimationStyle.requiresPremiumUnlock && !premiumUnlocked {
            gachaAnimationStyle = .mysteryCard
        }

        NotificationCenter.default.addObserver(self, selector: #selector(handlePremiumStatusDidChange), name: .premiumAnimationsStatusDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleAppDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        premiumStore.start()
        Task { [weak self] in
            self?.logAndShowStatus("Loading premium animation product…")
            await self?.premiumStore.loadProduct()
            await self?.premiumStore.refreshEntitlements()
            await MainActor.run {
                self?.handlePremiumStatusDidChange()
                self?.clearStatus()
            }
        }

        premiumStatusLabel.text = nil
        premiumStatusLabel.isHidden = true
        configureAnimationButton()
        
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var encryptFile: UISwitch!
    @IBOutlet weak var encryptPassword: UISwitch!
    @IBOutlet weak var applyButton: UIButton!
    @IBOutlet weak var setPassword: UISwitch!
    
    @IBOutlet weak var star1Text: UITextField!
    @IBOutlet weak var star2Text: UITextField!
    @IBOutlet weak var star3Text: UITextField!
    @IBOutlet weak var gachaAnimationButton: UIButton!
    @IBOutlet weak var premiumStatusLabel: UILabel!
    
    @IBAction func setPassword(_ sender: UISwitch) {
        if sender.isOn {
            passwordText.isHidden = false
        }
        else {
            passwordText.isHidden = true
        }
    }

    private func configureAnimationButton() {
        updateAnimationButtonTitle()

        let actions: [UIAction] = ImageGalleryModel.GachaAnimationStyle.allCases.map { style in
            let title = style.requiresPremiumUnlock && !premiumUnlocked ? "\(style.displayName) (Premium)" : style.displayName
            return UIAction(
                title: title,
                state: style == gachaAnimationStyle ? .on : .off
            ) { [weak self] _ in
                Task { [weak self] in
                    await self?.handleAnimationSelection(style)
                }
            }
        }

        gachaAnimationButton.menu = UIMenu(title: "", options: .displayInline, children: actions)
        gachaAnimationButton.showsMenuAsPrimaryAction = true
        gachaAnimationButton.changesSelectionAsPrimaryAction = false
    }

    private func updateAnimationButtonTitle() {
        gachaAnimationButton.setTitle(gachaAnimationStyle.displayName, for: .normal)
    }

    @objc private func handlePremiumStatusDidChange() {
        logger.log("Premium entitlement status changed. unlocked=\(self.premiumStore.isPremiumUnlocked, privacy: .public)")
        debugPrint("Premium entitlement status changed. unlocked=\(premiumStore.isPremiumUnlocked)")
        premiumUnlocked = premiumStore.isPremiumUnlocked
        if gachaAnimationStyle.requiresPremiumUnlock && !premiumUnlocked {
            gachaAnimationStyle = .mysteryCard
        }
        configureAnimationButton()
    }

    @objc private func handleAppDidBecomeActive() {
        logger.log("App became active while settings is visible. Refreshing premium entitlement state.")
        debugPrint("App became active while settings is visible. Refreshing premium entitlement state.")
        if purchaseInFlight {
            purchaseRoundTrippedThroughAppStore = true
            showStatus("Finishing App Store purchase…", autoClearAfter: nil)
            logger.log("Purchase is still in flight after app became active again.")
            debugPrint("Purchase is still in flight after app became active again.")
        }
        Task { [weak self] in
            await self?.premiumStore.refreshEntitlements()
            await MainActor.run {
                self?.handlePremiumStatusDidChange()
            }
        }
    }

    private func handleAnimationSelection(_ style: ImageGalleryModel.GachaAnimationStyle) async {
        view.endEditing(true)
        if !premiumStore.isStyleUnlocked(style) {
            logger.log("User selected locked premium animation: \(style.displayName, privacy: .public)")
            debugPrint("User selected locked premium animation: \(style.displayName)")
            await presentPremiumPurchasePrompt(for: style)
            return
        }

        logger.log("User selected animation: \(style.displayName, privacy: .public)")
        debugPrint("User selected animation: \(style.displayName)")
        gachaAnimationStyle = style
        configureAnimationButton()
        showStatus("\(style.displayName) selected", autoClearAfter: 2.0)
    }

    private func presentPremiumPurchasePrompt(for style: ImageGalleryModel.GachaAnimationStyle) async {
        view.endEditing(true)
        let priceText = premiumStore.premiumPriceDisplay ?? "$3"
        let alert = UIAlertController(
            title: "Unlock Premium Animations",
            message: "Get Spinning Star, Airport, and Slot Machine for \(priceText).",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Buy", style: .default) { [weak self] _ in
            Task {
                await self?.purchasePremiumAnimations(selecting: style)
            }
        })
        alert.addAction(UIAlertAction(title: "Restore Purchases", style: .default) { [weak self] _ in
            Task {
                await self?.restorePremiumAnimations(selecting: style)
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    private func purchasePremiumAnimations(selecting style: ImageGalleryModel.GachaAnimationStyle) async {
        purchaseInFlight = true
        purchaseRoundTrippedThroughAppStore = false
        logAndShowStatus("Connecting to the App Store…")
        let outcome = await premiumStore.purchasePremiumAnimations()
        await MainActor.run {
            self.purchaseInFlight = false
            self.handlePurchaseOutcome(outcome, selecting: style)
        }
    }

    private func restorePremiumAnimations(selecting style: ImageGalleryModel.GachaAnimationStyle) async {
        logAndShowStatus("Restoring premium purchase…")
        let outcome = await premiumStore.restorePurchases()
        await MainActor.run {
            self.handlePurchaseOutcome(outcome, selecting: style)
        }
    }

    private func handlePurchaseOutcome(_ outcome: PremiumAnimationsStore.PurchaseOutcome, selecting style: ImageGalleryModel.GachaAnimationStyle) {
        logger.log("Purchase flow finished with outcome.")
        debugPrint("Purchase flow finished with outcome: \(String(describing: outcome))")
        switch outcome {
        case .success:
            premiumUnlocked = premiumStore.isPremiumUnlocked
            gachaAnimationStyle = style
            configureAnimationButton()
            showStatus("Premium animations unlocked", autoClearAfter: 4.0)
            presentSimpleAlert(title: "Unlocked", message: "Premium animations are now unlocked.")
        case .cancelled:
            if purchaseRoundTrippedThroughAppStore {
                logger.log("Purchase returned cancelled after App Store sign-in/purchase round-trip. Treating as interrupted flow.")
                debugPrint("Purchase returned cancelled after App Store sign-in/purchase round-trip. Treating as interrupted flow.")
                showStatus("Sign-in finished. Tap Buy again to continue.", autoClearAfter: 5.0)
                presentInterruptedPurchaseAlert(for: style)
            } else {
                showStatus("Purchase cancelled", autoClearAfter: 3.0)
            }
        case .pending:
            showStatus("Purchase pending approval", autoClearAfter: 4.0)
            presentSimpleAlert(title: "Purchase Pending", message: "Your premium animation purchase is still pending approval.")
        case .interruptedNeedsRetry:
            showStatus("Sign-in finished. Tap Buy again to continue.", autoClearAfter: 5.0)
            presentInterruptedPurchaseAlert(for: style)
        case .failed(let message):
            showStatus("Premium unlock failed", autoClearAfter: 4.0)
            presentSimpleAlert(title: "Purchase Unavailable", message: message)
        }
        purchaseRoundTrippedThroughAppStore = false
    }

    private func presentSimpleAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alert, animated: true)
    }

    private func presentInterruptedPurchaseAlert(for style: ImageGalleryModel.GachaAnimationStyle) {
        let alert = UIAlertController(
            title: "Continue Purchase",
            message: "Apple sign-in completed, but the premium purchase did not finish yet. Tap Buy again to continue.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Buy Again", style: .default) { [weak self] _ in
            Task {
                await self?.purchasePremiumAnimations(selecting: style)
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    private func logAndShowStatus(_ message: String) {
        logger.log("\(message, privacy: .public)")
        debugPrint(message)
        showStatus(message, autoClearAfter: nil)
    }

    private func showStatus(_ message: String, autoClearAfter delay: TimeInterval?) {
        statusResetTask?.cancel()
        premiumStatusLabel.text = message
        premiumStatusLabel.isHidden = false
        guard let delay else { return }
        let workItem = DispatchWorkItem { [weak self] in
            self?.premiumStatusLabel.text = nil
            self?.premiumStatusLabel.isHidden = true
        }
        statusResetTask = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
    }

    private func clearStatus() {
        statusResetTask?.cancel()
        statusResetTask = nil
        premiumStatusLabel.text = nil
        premiumStatusLabel.isHidden = true
    }


    
    @IBAction func apply(_ sender: UIButton) {
        /*
        if passwordText.text != "" {
            if let delegate = delegate {
                delegate.doSomethingWith(pw: passwordText.text!, isEN: encryptFile.isOn)
                _ = navigationController?.popViewController(animated: true)
            }
        }
         */
        if (passwordText.text == "" || !setPassword.isOn) && encryptFile.isOn {
            let alert = UIAlertController(title: "Encrypt without Password", message: "To encrypt, you must also set password.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default))
            present(alert, animated: true)
        }
        else if !passwordText.isHidden && passwordText.text == "" {
            let alert = UIAlertController(title: "Empty Password", message: "Password field is empty", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default))
            present(alert, animated: true)
        }
        else if passwordText.isHidden && encryptPassword.isOn {
            let alert = UIAlertController(title: "Encrypt without Password", message: "To encrypt password, you must also set password", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default))
            present(alert, animated: true)
        }
        else if !encryptFile.isOn && encryptPassword.isOn {
            let alert = UIAlertController(title: "Encrypt File", message: "To encrypt password, you must also enable Encrypt file", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default))
            present(alert, animated: true)
        }
        else {
            if let delegate = delegate {
                if let star1Float = Float(star1Text.text ?? ""), let star2Float = Float(star2Text.text ?? ""), let star3Float = Float(star3Text.text ?? "") {
                    if (star1Float + star2Float + star3Float) == 100 {
                        delegate.doSomethingWith(
                            pwSwitch: setPassword.isOn,
                            pw: passwordText.text!,
                            isEN: encryptFile.isOn,
                            isPWEN: encryptPassword.isOn,
                            star1Probability: star1Float,
                            star2Probability: star2Float,
                            star3Probability: star3Float,
                            gachaAnimationStyle: gachaAnimationStyle
                        )
                        _ = navigationController?.popViewController(animated: true)
                    }
                    else {
                        let alert = UIAlertController(title: "Incorrect Probabilities", message: "Sum of probabilities is not equal to 100", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default))
                        present(alert, animated: true)
                    }
                }
                else {
                    let alert = UIAlertController(title: "Incorrect Probabilities", message: "Probability text is not a decimal number", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default))
                    present(alert, animated: true)
                }
            }
        }
        
    }
    

}
