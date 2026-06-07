//
//  ImageSearchViewController.swift
//  Image Gallery v2
//
//  Created by Raj Gupta on 2024/03/03.
//  Copyright © 2024 SoulfulMachine. All rights reserved.
//

import Foundation
import UIKit

class ImageSearchViewController: UIViewController, UIScrollViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate {
    var imageGallery: ImageGalleryModel?
    var filteredImageGallery: ImageGalleryModel?
    
    @IBOutlet weak var searchText: UITextField!
    @IBOutlet weak var searchStars: UISegmentedControl!
    @IBOutlet weak var searchFavorite: UISwitch!
    
    private let formScrollView = UIScrollView()
    private let formStackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchText.delegate = self
        searchText.autocapitalizationType = .words
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
        
        configureSearchFormLayout()
        
        // Add observer for updated image details
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdatedImageDetails), name: .updatedImageDetails, object: nil)
    }
    
    @objc func handleUpdatedImageDetails(notification: Notification) {
        if let imageURL = notification.userInfo?["imageURL"] {
            let imageTitle = notification.userInfo?["imageTitle"]
            let stars = notification.userInfo?["stars"]
            let favorite = notification.userInfo?["favorite"]
            imageGallery?.updateGalleryContent(byURL: imageURL as! String, newTitle: imageTitle as? String, newStars: stars as? Int, newFavorite: favorite as? Bool)
        }
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
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
    
    
    func tappedApplyButton() {
        
        let filteredContents = imageGallery?.galleryContents.filter { content in
            var matchesText: Bool
            if let searchTextString = self.searchText.text?.trimmingCharacters(in: .whitespaces), !searchTextString.isEmpty {
                if let contentImageTitle = content.imageTitle {
                    let contentImageTitleLowerCased = contentImageTitle.lowercased()
                    matchesText = contentImageTitleLowerCased.contains(searchTextString.lowercased())
                } else {
                    matchesText = false
                }
            } else {
                matchesText = true
            }
            
            let matchesStars = self.searchStars.selectedSegmentIndex == 0 || content.stars == self.searchStars.selectedSegmentIndex
            let matchesFavorite = !self.searchFavorite.isOn || content.favorite == self.searchFavorite.isOn
            
            return matchesText && matchesStars && matchesFavorite
        }
        if let filteredContents = filteredContents {
            filteredImageGallery = ImageGalleryModel(title: "FilteredGallery")
            filteredImageGallery?.galleryContents = filteredContents
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFilteredGallery" {
            if let filteredVC = segue.destination as? FilteredImageGalleryCollectionViewController {
                tappedApplyButton()
                filteredVC.imageGallery = filteredImageGallery
                filteredVC.showingFavorites = self.searchFavorite.isOn
            }
        }
    }
    
    @objc private func showFilteredGalleryResults() {
        performSegue(withIdentifier: "showFilteredGallery", sender: self)
    }
    
    private func configureSearchFormLayout() {
        let preservedControls = [searchText, searchStars, searchFavorite].compactMap { $0 }
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
        titleLabel.text = "Search Images"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 26, weight: .semibold)
        titleLabel.textColor = UIColor(red: 0.262745098, green: 0.7333333333, blue: 0.5294117647, alpha: 1)
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Filter by title, star level, and favorite status."
        subtitleLabel.textAlignment = .center
        subtitleLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        subtitleLabel.textColor = UIColor(white: 0.82, alpha: 1.0)
        subtitleLabel.numberOfLines = 0
        
        searchText.borderStyle = .roundedRect
        
        let textSection = makeSection(title: "Title Contains", control: searchText)
        let starsSection = makeSection(title: "Stars", control: searchStars)
        
        let favoriteLabel = UILabel()
        favoriteLabel.text = "Favorites Only"
        favoriteLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        favoriteLabel.textColor = UIColor(red: 0.262745098, green: 0.7333333333, blue: 0.5294117647, alpha: 1)
        
        let favoriteHint = UILabel()
        favoriteHint.text = "Turn this on to show only favorite images."
        favoriteHint.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        favoriteHint.textColor = UIColor(white: 0.82, alpha: 1.0)
        favoriteHint.numberOfLines = 0
        
        let favoriteRow = UIStackView()
        favoriteRow.axis = .horizontal
        favoriteRow.alignment = .center
        favoriteRow.spacing = 12
        
        let favoriteTextStack = UIStackView(arrangedSubviews: [favoriteLabel, favoriteHint])
        favoriteTextStack.axis = .vertical
        favoriteTextStack.spacing = 4
        
        let favoriteSpacer = UIView()
        favoriteSpacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        favoriteRow.addArrangedSubview(favoriteTextStack)
        favoriteRow.addArrangedSubview(favoriteSpacer)
        favoriteRow.addArrangedSubview(searchFavorite)
        
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
        applyButton.configuration?.title = "Show Results"
        applyButton.configuration?.cornerStyle = .large
        applyButton.configuration?.baseBackgroundColor = UIColor(red: 0.262745098, green: 0.7333333333, blue: 0.5294117647, alpha: 1)
        applyButton.configuration?.baseForegroundColor = .black
        applyButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        applyButton.addTarget(self, action: #selector(showFilteredGalleryResults), for: .touchUpInside)
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
