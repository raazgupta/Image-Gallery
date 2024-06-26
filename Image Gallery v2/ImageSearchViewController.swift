//
//  ImageSearchViewController.swift
//  Image Gallery v2
//
//  Created by Raj Gupta on 2024/03/03.
//  Copyright © 2024 SoulfulMachine. All rights reserved.
//

import Foundation
import UIKit

class ImageSearchViewController: UIViewController, UIScrollViewDelegate, UITextFieldDelegate {
    var imageGallery: ImageGalleryModel?
    var filteredImageGallery: ImageGalleryModel?
    
    @IBOutlet weak var searchText: UITextField!
    @IBOutlet weak var searchStars: UISegmentedControl!
    @IBOutlet weak var searchFavorite: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchText.delegate = self
        searchText.autocapitalizationType = .words
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
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
    
    
    
    
}
