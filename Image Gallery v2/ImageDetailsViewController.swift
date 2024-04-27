//
//  ImageDetailsViewController.swift
//  Image Gallery v2
//
//  Created by Raj Gupta on 2024/02/24.
//  Copyright © 2024 SoulfulMachine. All rights reserved.
//

import Foundation
import UIKit

protocol ImageDetailsViewControllerDelegate: AnyObject {
    func didUpdateImageDetails(imageTitle: String?, stars: Int?, favorite: Bool?)
}

class ImageDetailsViewController: UIViewController, UIScrollViewDelegate, UITextFieldDelegate {
    
    weak var delegate: ImageDetailsViewControllerDelegate?
    
    var imageTitle: String?
    var stars: Int?
    var favorite: Bool?
    var imageURL: String?
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var starsSegmentedControl: UISegmentedControl!
    @IBOutlet weak var favoriteSwitch: UISwitch!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleTextField.delegate = self
        titleTextField.autocapitalizationType = .words
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        if let imageTitle = imageTitle {
            titleTextField.text = imageTitle
        }
        if let stars = stars {
            starsSegmentedControl.selectedSegmentIndex = stars - 1
        }
        if let favorite = favorite {
            favoriteSwitch.isOn = favorite
        }
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    @IBAction func applyButtonTapped(_ sender: Any) {
        imageTitle = titleTextField.text
        stars = starsSegmentedControl.selectedSegmentIndex + 1
        favorite = favoriteSwitch.isOn
        delegate?.didUpdateImageDetails(imageTitle: imageTitle, stars: stars, favorite: favorite)
        NotificationCenter.default.post(name: .updatedImageDetails, object: nil, userInfo: ["imageURL": imageURL ?? "", "imageTitle": imageTitle ?? "", "stars": stars ?? 1, "favorite": favorite ?? false])
        self.navigationController?.popViewController(animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

extension ImageViewController: ImageDetailsViewControllerDelegate {
    func didUpdateImageDetails(imageTitle: String?, stars: Int?, favorite: Bool?) {
        self.imageTitle = imageTitle
        self.stars = stars
        self.favorite = favorite
        
        self.title = imageTitle
    }
}


