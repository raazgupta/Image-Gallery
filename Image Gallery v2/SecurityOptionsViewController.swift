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

class SecurityOptionsViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {
    private let premiumStore = PremiumAnimationsStore.shared
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "ImageKeeper", category: "SecurityOptions")
    private var premiumUnlocked = false
    private var statusResetTask: DispatchWorkItem?
    private var purchaseInFlight = false
    private var purchaseRoundTrippedThroughAppStore = false
    private weak var activeTextField: UITextField?

    private let formScrollView = UIScrollView()
    private let formStackView = UIStackView()
    private let heroTitleLabel = UILabel()
    private let heroSubtitleLabel = UILabel()
    private let passwordSection = UIView()
    private let probabilitySection = UIView()
    private let animationSection = UIView()
    private let securitySection = UIView()
    private let passwordFieldContainer = UIView()
    private let passwordFieldStack = UIStackView()
    private let probabilityFieldsStack = UIStackView()
    private let animationStatusStack = UIStackView()

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

    override func viewDidLoad() {
        super.viewDidLoad()

        passwordText.delegate = self
        star1Text.delegate = self
        star2Text.delegate = self
        star3Text.delegate = self
        passwordText.autocapitalizationType = .none
        passwordText.autocorrectionType = .no
        passwordText.isSecureTextEntry = true
        star1Text.keyboardType = .decimalPad
        star2Text.keyboardType = .decimalPad
        star3Text.keyboardType = .decimalPad
        
        star1Text.text = String(star1Probability)
        star2Text.text = String(star2Probability)
        star3Text.text = String(star3Probability)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard(_:)))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
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
        configureSettingsFormLayout()
        configureAnimationButton()
        updatePasswordVisibility(animated: false)

        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is UIControl {
            return false
        }
        return true
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
        updatePasswordVisibility(animated: true)
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

    private func configureSettingsFormLayout() {
        let preservedControls = [
            passwordText,
            encryptFile,
            encryptPassword,
            applyButton,
            setPassword,
            star1Text,
            star2Text,
            star3Text,
            gachaAnimationButton,
            premiumStatusLabel
        ].compactMap { $0 }
        let preservedIds = Set(preservedControls.map { ObjectIdentifier($0) })

        for subview in view.subviews where !preservedIds.contains(ObjectIdentifier(subview)) {
            subview.isHidden = true
        }

        preservedControls.forEach {
            $0.removeFromSuperview()
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        view.backgroundColor = .black
        navigationItem.title = nil

        formScrollView.translatesAutoresizingMaskIntoConstraints = false
        formScrollView.alwaysBounceVertical = true
        formScrollView.keyboardDismissMode = .interactive

        formStackView.translatesAutoresizingMaskIntoConstraints = false
        formStackView.axis = .vertical
        formStackView.spacing = 18
        formStackView.alignment = .fill
        formStackView.isLayoutMarginsRelativeArrangement = true
        formStackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 28, leading: 20, bottom: 28, trailing: 20)

        heroTitleLabel.text = "Settings"
        heroTitleLabel.textAlignment = .center
        heroTitleLabel.font = UIFont.systemFont(ofSize: 26, weight: .semibold)
        heroTitleLabel.textColor = UIColor(red: 0.262745098, green: 0.7333333333, blue: 0.5294117647, alpha: 1)

        heroSubtitleLabel.text = "Control security, random-roll probabilities, and premium animation style."
        heroSubtitleLabel.textAlignment = .center
        heroSubtitleLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        heroSubtitleLabel.textColor = UIColor(white: 0.82, alpha: 1.0)
        heroSubtitleLabel.numberOfLines = 0

        passwordText.borderStyle = .roundedRect
        star1Text.borderStyle = .roundedRect
        star2Text.borderStyle = .roundedRect
        star3Text.borderStyle = .roundedRect

        view.addSubview(formScrollView)
        formScrollView.addSubview(formStackView)

        NSLayoutConstraint.activate([
            formScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            formScrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            formScrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            formScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            formStackView.topAnchor.constraint(equalTo: formScrollView.contentLayoutGuide.topAnchor),
            formStackView.leadingAnchor.constraint(equalTo: formScrollView.contentLayoutGuide.leadingAnchor),
            formStackView.trailingAnchor.constraint(equalTo: formScrollView.contentLayoutGuide.trailingAnchor),
            formStackView.bottomAnchor.constraint(equalTo: formScrollView.contentLayoutGuide.bottomAnchor),
            formStackView.widthAnchor.constraint(equalTo: formScrollView.frameLayoutGuide.widthAnchor)
        ])

        configurePasswordSection()
        configureSecuritySection()
        configureProbabilitySection()
        configureAnimationSection()

        applyButton.configuration = .filled()
        applyButton.configuration?.title = "Apply Settings"
        applyButton.configuration?.cornerStyle = .large
        applyButton.configuration?.baseBackgroundColor = UIColor(red: 0.262745098, green: 0.7333333333, blue: 0.5294117647, alpha: 1)
        applyButton.configuration?.baseForegroundColor = .black
        applyButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        NSLayoutConstraint.activate([
            applyButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 52)
        ])

        [heroTitleLabel, heroSubtitleLabel, passwordSection, securitySection, probabilitySection, animationSection, applyButton].forEach {
            formStackView.addArrangedSubview($0)
        }
    }

    private func configurePasswordSection() {
        let passwordToggleRow = makeToggleRow(
            title: "Set Password",
            subtitle: "Protect the gallery with a password before opening it.",
            toggle: setPassword
        )

        let passwordFieldLabel = makeSectionLabel("Password")
        passwordFieldStack.axis = .vertical
        passwordFieldStack.spacing = 10
        passwordFieldStack.alignment = .fill
        passwordFieldStack.translatesAutoresizingMaskIntoConstraints = false
        passwordFieldStack.addArrangedSubview(passwordFieldLabel)
        passwordFieldStack.addArrangedSubview(passwordText)

        passwordFieldContainer.translatesAutoresizingMaskIntoConstraints = false
        passwordFieldContainer.addSubview(passwordFieldStack)
        NSLayoutConstraint.activate([
            passwordFieldStack.topAnchor.constraint(equalTo: passwordFieldContainer.topAnchor),
            passwordFieldStack.leadingAnchor.constraint(equalTo: passwordFieldContainer.leadingAnchor),
            passwordFieldStack.trailingAnchor.constraint(equalTo: passwordFieldContainer.trailingAnchor),
            passwordFieldStack.bottomAnchor.constraint(equalTo: passwordFieldContainer.bottomAnchor)
        ])

        let passwordStack = UIStackView(arrangedSubviews: [passwordToggleRow, passwordFieldContainer])
        passwordStack.axis = .vertical
        passwordStack.spacing = 14
        passwordStack.alignment = .fill

        configureSection(passwordSection, title: "Access", content: passwordStack)
    }

    private func configureSecuritySection() {
        let encryptFileRow = makeToggleRow(
            title: "Encrypt File",
            subtitle: "Encrypt gallery data on disk when a password is set.",
            toggle: encryptFile
        )
        let encryptPasswordRow = makeToggleRow(
            title: "Encrypt Password",
            subtitle: "Encrypt the stored password and require file encryption too.",
            toggle: encryptPassword
        )

        let stack = UIStackView(arrangedSubviews: [encryptFileRow, encryptPasswordRow])
        stack.axis = .vertical
        stack.spacing = 14
        stack.alignment = .fill

        configureSection(securitySection, title: "Encryption", content: stack)
    }

    private func configureProbabilitySection() {
        probabilityFieldsStack.axis = .vertical
        probabilityFieldsStack.spacing = 12
        probabilityFieldsStack.alignment = .fill

        probabilityFieldsStack.addArrangedSubview(makeProbabilityRow(title: "1-Star Chance", textField: star1Text))
        probabilityFieldsStack.addArrangedSubview(makeProbabilityRow(title: "2-Star Chance", textField: star2Text))
        probabilityFieldsStack.addArrangedSubview(makeProbabilityRow(title: "3-Star Chance", textField: star3Text))

        let footnoteLabel = UILabel()
        footnoteLabel.text = "All three probability values must add up to 100."
        footnoteLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        footnoteLabel.textColor = UIColor(white: 0.76, alpha: 1.0)
        footnoteLabel.numberOfLines = 0
        probabilityFieldsStack.addArrangedSubview(footnoteLabel)

        configureSection(probabilitySection, title: "Random Roll Rates", content: probabilityFieldsStack)
    }

    private func configureAnimationSection() {
        gachaAnimationButton.configuration = .tinted()
        gachaAnimationButton.configuration?.cornerStyle = .large
        gachaAnimationButton.configuration?.baseBackgroundColor = UIColor(red: 0.262745098, green: 0.7333333333, blue: 0.5294117647, alpha: 0.2)
        gachaAnimationButton.configuration?.baseForegroundColor = UIColor(red: 0.262745098, green: 0.7333333333, blue: 0.5294117647, alpha: 1)
        gachaAnimationButton.contentHorizontalAlignment = .leading
        premiumStatusLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        premiumStatusLabel.textColor = UIColor(white: 0.82, alpha: 1.0)
        premiumStatusLabel.numberOfLines = 0

        animationStatusStack.axis = .vertical
        animationStatusStack.spacing = 10
        animationStatusStack.alignment = .fill
        animationStatusStack.addArrangedSubview(gachaAnimationButton)
        animationStatusStack.addArrangedSubview(premiumStatusLabel)

        configureSection(animationSection, title: "Gacha Animation", content: animationStatusStack)
    }

    private func configureSection(_ sectionView: UIView, title: String, content: UIView) {
        let titleLabel = makeSectionLabel(title)

        let stack = UIStackView(arrangedSubviews: [titleLabel, content])
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .fill

        sectionView.backgroundColor = UIColor(white: 1.0, alpha: 0.06)
        sectionView.layer.cornerRadius = 16
        sectionView.translatesAutoresizingMaskIntoConstraints = false
        sectionView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        stack.translatesAutoresizingMaskIntoConstraints = false
        sectionView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: sectionView.layoutMarginsGuide.topAnchor),
            stack.leadingAnchor.constraint(equalTo: sectionView.layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: sectionView.layoutMarginsGuide.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: sectionView.layoutMarginsGuide.bottomAnchor)
        ])
    }

    private func makeSectionLabel(_ title: String) -> UILabel {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        titleLabel.textColor = UIColor(red: 0.262745098, green: 0.7333333333, blue: 0.5294117647, alpha: 1)
        return titleLabel
    }

    private func makeToggleRow(title: String, subtitle: String, toggle: UISwitch) -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        titleLabel.textColor = UIColor(red: 0.262745098, green: 0.7333333333, blue: 0.5294117647, alpha: 1)

        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        subtitleLabel.textColor = UIColor(white: 0.82, alpha: 1.0)
        subtitleLabel.numberOfLines = 0

        let labelsStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        labelsStack.axis = .vertical
        labelsStack.spacing = 4
        labelsStack.alignment = .fill

        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [labelsStack, spacer, toggle])
        row.axis = .horizontal
        row.spacing = 12
        row.alignment = .center
        return row
    }

    private func makeProbabilityRow(title: String, textField: UITextField) -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = UIColor(white: 0.9, alpha: 1.0)

        let suffixLabel = UILabel()
        suffixLabel.text = "%"
        suffixLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        suffixLabel.textColor = UIColor(white: 0.82, alpha: 1.0)

        textField.textAlignment = .right
        textField.widthAnchor.constraint(equalToConstant: 92).isActive = true

        let row = UIStackView(arrangedSubviews: [titleLabel, UIView(), textField, suffixLabel])
        row.axis = .horizontal
        row.spacing = 10
        row.alignment = .center
        return row
    }

    private func updatePasswordVisibility(animated: Bool) {
        let updates = {
            self.passwordFieldContainer.isHidden = !self.setPassword.isOn
            self.passwordText.isHidden = !self.setPassword.isOn
        }

        guard animated else {
            updates()
            return
        }

        UIView.animate(withDuration: 0.2, animations: updates)
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if activeTextField === textField {
            activeTextField = nil
        }
    }

    @objc private func handleKeyboardWillChangeFrame(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curveValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else {
            return
        }

        let keyboardFrame = view.convert(keyboardFrameValue.cgRectValue, from: nil)
        let overlap = max(0, view.bounds.maxY - keyboardFrame.minY)
        let bottomInset = max(0, overlap - view.safeAreaInsets.bottom) + 16

        let options = UIView.AnimationOptions(rawValue: curveValue << 16)
        UIView.animate(withDuration: duration, delay: 0, options: options) {
            self.formScrollView.contentInset.bottom = bottomInset
            self.formScrollView.verticalScrollIndicatorInsets.bottom = bottomInset
            if let activeTextField = self.activeTextField {
                let visibleRect = activeTextField.convert(activeTextField.bounds, to: self.formScrollView)
                self.formScrollView.scrollRectToVisible(visibleRect.insetBy(dx: 0, dy: -24), animated: false)
            }
        }
    }

    @objc private func handleKeyboardWillHide(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curveValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else {
            return
        }

        let options = UIView.AnimationOptions(rawValue: curveValue << 16)
        UIView.animate(withDuration: duration, delay: 0, options: options) {
            self.formScrollView.contentInset.bottom = 0
            self.formScrollView.verticalScrollIndicatorInsets.bottom = 0
        }
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
