//
//  SecurityOptionsViewController.swift
//  Image Gallery v2
//
//  Created by Raj Gupta on 2020/08/26.
//  Copyright © 2020 SoulfulMachine. All rights reserved.
//

import UIKit

protocol SecurityOptionsViewControllerDelegate: NSObjectProtocol {
    func doSomethingWith(pwSwitch: Bool, pw: String, isEN: Bool, star1Probability: Float, star2Probability: Float, star3Probability: Float)
}

class SecurityOptionsViewController: UIViewController, UITextFieldDelegate {
    
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
        
        if galleryPW != "" {
            setPassword.isOn = true
            passwordText.isHidden = false
            passwordText.text = galleryPW
        }
        
    }
    
    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var encryptFile: UISwitch!
    @IBOutlet weak var applyButton: UIButton!
    @IBOutlet weak var setPassword: UISwitch!
    
    @IBOutlet weak var star1Text: UITextField!
    @IBOutlet weak var star2Text: UITextField!
    @IBOutlet weak var star3Text: UITextField!
    
    @IBAction func setPassword(_ sender: UISwitch) {
        if sender.isOn {
            passwordText.isHidden = false
        }
        else {
            passwordText.isHidden = true
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
        else {
            if let delegate = delegate {
                if let star1Float = Float(star1Text.text ?? ""), let star2Float = Float(star2Text.text ?? ""), let star3Float = Float(star3Text.text ?? "") {
                    if (star1Float + star2Float + star3Float) == 100 {
                        delegate.doSomethingWith(pwSwitch: setPassword.isOn , pw: passwordText.text!, isEN: encryptFile.isOn, star1Probability: star1Float, star2Probability: star2Float, star3Probability: star3Float)
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
