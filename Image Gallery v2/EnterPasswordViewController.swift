//
//  EnterPasswordViewController.swift
//  Image Gallery v2
//
//  Created by Raj Gupta on 2020/08/27.
//  Copyright © 2020 SoulfulMachine. All rights reserved.
//

import UIKit

protocol EnterPasswordViewContollerDelegate: NSObjectProtocol {
    func passwordResult(showImages: Bool, showEnterPassword: Bool)
}

class EnterPasswordViewController: UIViewController, UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        checkPassword()
        return true
    }
    
    weak var delegate: EnterPasswordViewContollerDelegate?
    @IBOutlet weak var passwordText: UITextField! {
        didSet {
            passwordText.isSecureTextEntry = true
            passwordText.delegate = self
        }
    }
    @IBOutlet weak var enterPasswordLabel: UILabel!
    @IBOutlet weak var submitButton: UIButton! {
        didSet {
            submitButton.layer.cornerRadius = 10.0
            submitButton.accessibilityLabel = "Submit Password"
            submitButton.accessibilityHint = "Submits the entered password for validation"
        }
    }
    @IBOutlet weak var cancelButton: UIButton! {
        didSet {
            cancelButton.layer.cornerRadius = 10.0
            cancelButton.accessibilityLabel = "Cancel"
            cancelButton.accessibilityHint = "Cancels password entry."
        }
    }
    
    var correctPassword: String?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        passwordText.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard(_:)))
        self.view.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        passwordText.resignFirstResponder()
    }
    
    @IBAction func submit(_ sender: UIButton) {
        checkPassword()
    }
    
    func checkPassword(){
        guard let pText = passwordText.text, !pText.isEmpty else {
            enterPasswordLabel.text = "Password cannot be empty"
            return
        }
        
        if let cText = correctPassword, pText == cText {
            delegate?.passwordResult(showImages: true, showEnterPassword: false)
            dismiss(animated: true)
        }
        else {
            enterPasswordLabel.text = "Incorrect Password"
            enterPasswordLabel.textColor = .red
            UIView.animate(withDuration: 0.1, animations: {
                            self.enterPasswordLabel.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                        }) { _ in
                            UIView.animate(withDuration: 0.1) {
                                self.enterPasswordLabel.transform = CGAffineTransform.identity
                            }
                        }
        }
        
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        delegate?.passwordResult(showImages: false, showEnterPassword: false)
        dismiss(animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

