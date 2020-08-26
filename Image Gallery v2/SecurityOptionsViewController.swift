//
//  SecurityOptionsViewController.swift
//  Image Gallery v2
//
//  Created by Raj Gupta on 2020/08/26.
//  Copyright © 2020 SoulfulMachine. All rights reserved.
//

import UIKit

protocol SecurityOptionsViewControllerDelegate: NSObjectProtocol {
    func doSomethingWith(data: String)
}

class SecurityOptionsViewController: UIViewController {

    weak var delegate: SecurityOptionsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
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
        if passwordText.text != "" {
            if let delegate = delegate {
                delegate.doSomethingWith(data: passwordText.text!)
            }
        }
        _ = navigationController?.popViewController(animated: true)
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