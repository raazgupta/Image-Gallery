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
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var enterPasswordLabel: UILabel!
    
    var correctPassword: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        passwordText.delegate = self
    }
    
    @IBAction func submit(_ sender: UIButton) {
        checkPassword()
    }
    
    func checkPassword(){
        if let pText = passwordText.text {
            if let cText = correctPassword {
                if pText == cText {
                    delegate?.passwordResult(showImages: true, showEnterPassword: false)
                    dismiss(animated: true)
                }
                else {
                    enterPasswordLabel.text = "Incorrect Password"
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

