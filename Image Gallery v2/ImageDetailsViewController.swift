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

class ImageDetailsViewController: UIViewController, UIScrollViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    weak var delegate: ImageDetailsViewControllerDelegate?
    
    var imageTitle: String?
    var stars: Int?
    var favorite: Bool?
    var imageURL: String?
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var starsSegmentedControl: UISegmentedControl!
    @IBOutlet weak var favoriteSwitch: UISwitch!
    
    private let formScrollView = UIScrollView()
    private let formStackView = UIStackView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleTextField.delegate = self
        titleTextField.autocapitalizationType = .words
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
        
        configureDetailsFormLayout()
        
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

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is UIControl {
            return false
        }
        return true
    }
    
    private func configureDetailsFormLayout() {
        let preservedControls = [titleTextField, starsSegmentedControl, favoriteSwitch].compactMap { $0 }
        let preservedIds = Set(preservedControls.map { ObjectIdentifier($0) })
        for subview in view.subviews where !preservedIds.contains(ObjectIdentifier(subview)) {
            subview.isHidden = true
        }
        
        preservedControls.forEach { control in
            control.removeFromSuperview()
            control.translatesAutoresizingMaskIntoConstraints = false
        }
        
        view.backgroundColor = .black
        navigationItem.title = nil
        titleTextField.borderStyle = .roundedRect
        
        formScrollView.translatesAutoresizingMaskIntoConstraints = false
        formScrollView.alwaysBounceVertical = true
        formScrollView.keyboardDismissMode = .interactive
        
        formStackView.translatesAutoresizingMaskIntoConstraints = false
        formStackView.axis = .vertical
        formStackView.spacing = 18
        formStackView.alignment = .fill
        formStackView.isLayoutMarginsRelativeArrangement = true
        formStackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 28, leading: 20, bottom: 28, trailing: 20)
        
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
        
        let titleLabel = UILabel()
        titleLabel.text = "Image Details"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 26, weight: .semibold)
        titleLabel.textColor = UIColor(red: 0.262745098, green: 0.7333333333, blue: 0.5294117647, alpha: 1)
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Update the title, rarity, and favorite status for this image."
        subtitleLabel.textAlignment = .center
        subtitleLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        subtitleLabel.textColor = UIColor(white: 0.82, alpha: 1.0)
        subtitleLabel.numberOfLines = 0
        
        let textSection = makeSection(title: "Title", control: titleTextField)
        let starsSection = makeSection(title: "Star Level", control: starsSegmentedControl)
        
        let favoriteLabel = UILabel()
        favoriteLabel.text = "Favorite"
        favoriteLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        favoriteLabel.textColor = UIColor(red: 0.262745098, green: 0.7333333333, blue: 0.5294117647, alpha: 1)
        
        let favoriteHint = UILabel()
        favoriteHint.text = "Keep this on to include the image in favorite-only views."
        favoriteHint.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        favoriteHint.textColor = UIColor(white: 0.82, alpha: 1.0)
        favoriteHint.numberOfLines = 0
        
        let favoriteTextStack = UIStackView(arrangedSubviews: [favoriteLabel, favoriteHint])
        favoriteTextStack.axis = .vertical
        favoriteTextStack.spacing = 4
        
        let favoriteSpacer = UIView()
        favoriteSpacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        let favoriteRow = UIStackView(arrangedSubviews: [favoriteTextStack, favoriteSpacer, favoriteSwitch])
        favoriteRow.axis = .horizontal
        favoriteRow.alignment = .center
        favoriteRow.spacing = 12
        
        let favoriteSection = UIView()
        favoriteSection.backgroundColor = UIColor(white: 1.0, alpha: 0.06)
        favoriteSection.layer.cornerRadius = 16
        favoriteSection.translatesAutoresizingMaskIntoConstraints = false
        favoriteSection.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        favoriteRow.translatesAutoresizingMaskIntoConstraints = false
        favoriteSection.addSubview(favoriteRow)
        NSLayoutConstraint.activate([
            favoriteRow.topAnchor.constraint(equalTo: favoriteSection.layoutMarginsGuide.topAnchor),
            favoriteRow.leadingAnchor.constraint(equalTo: favoriteSection.layoutMarginsGuide.leadingAnchor),
            favoriteRow.trailingAnchor.constraint(equalTo: favoriteSection.layoutMarginsGuide.trailingAnchor),
            favoriteRow.bottomAnchor.constraint(equalTo: favoriteSection.layoutMarginsGuide.bottomAnchor)
        ])
        
        let applyButton = UIButton(type: .system)
        applyButton.translatesAutoresizingMaskIntoConstraints = false
        applyButton.configuration = .filled()
        applyButton.configuration?.title = "Apply Changes"
        applyButton.configuration?.cornerStyle = .large
        applyButton.configuration?.baseBackgroundColor = UIColor(red: 0.262745098, green: 0.7333333333, blue: 0.5294117647, alpha: 1)
        applyButton.configuration?.baseForegroundColor = .black
        applyButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        applyButton.addTarget(self, action: #selector(applyButtonTapped(_:)), for: .touchUpInside)
        NSLayoutConstraint.activate([
            applyButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 52)
        ])
        
        [titleLabel, subtitleLabel, textSection, starsSection, favoriteSection, applyButton].forEach {
            formStackView.addArrangedSubview($0)
        }
    }
    
    private func makeSection(title: String, control: UIView) -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        titleLabel.textColor = UIColor(red: 0.262745098, green: 0.7333333333, blue: 0.5294117647, alpha: 1)
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, control])
        stack.axis = .vertical
        stack.spacing = 10
        stack.alignment = .fill
        
        let sectionView = UIView()
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
        
        return sectionView
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
