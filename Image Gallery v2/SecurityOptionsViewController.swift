//
//  SecurityOptionsViewController.swift
//  Image Gallery v2
//
//  Created by Raj Gupta on 2020/08/26.
//  Copyright © 2020 SoulfulMachine. All rights reserved.
//

import UIKit

protocol SecurityOptionsViewControllerDelegate: NSObjectProtocol {
    func doSomethingWith(pw: String, isEN: Bool)
}

class SecurityOptionsViewController: UIViewController, UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    weak var delegate: SecurityOptionsViewControllerDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        passwordText.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard(_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        passwordText.resignFirstResponder()
    }
    
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var encryptFile: UISwitch!
    
    
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
        if passwordText.text == "" && encryptFile.isOn {
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
                delegate.doSomethingWith(pw: passwordText.text!, isEN: encryptFile.isOn)
                _ = navigationController?.popViewController(animated: true)
            }
        }
        
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showImageGallery" {
            
        }
    }
    

}
