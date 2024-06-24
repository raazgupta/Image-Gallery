//
//  FilteredImageGalleryCollectionViewController.swift
//  Image Gallery v2
//
//  Created by Raj Gupta on 2024/03/04.
//  Copyright © 2024 SoulfulMachine. All rights reserved.
//

import Foundation

import UIKit

private let reuseIdentifier = "ImageCell"

protocol FilteredImageGalleryCollectionViewControllerDelegate: NSObjectProtocol {
    func deleteFilteredImage(url:String)
}

class FilteredImageGalleryCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var tappedImageIndex: Int?
    
    var imageGallery: ImageGalleryModel?
    var imageCellWidth: CGFloat = 180.0
    var flowLayout: UICollectionViewFlowLayout? {
        return collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
    }
    weak var delegate: FilteredImageGalleryCollectionViewControllerDelegate?
    var showingFavorites: Bool = false
    
    @IBAction func scaleCells(_ sender: UIPinchGestureRecognizer) {
        if sender.state == .ended {
            imageCellWidth = imageCellWidth * sender.scale
            if let maxWidth = collectionView?.contentSize.width {
                if imageCellWidth >= maxWidth {
                    imageCellWidth = maxWidth
                }
            }
            flowLayout?.invalidateLayout()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
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
    
    @objc func refreshImageCells() {
        collectionView.reloadData()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let imageGallery = imageGallery {
            return imageGallery.galleryContents.count
        }
        else {
            return 0
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell2", for: indexPath)
        
        // Configure the cell
        if let imageGallery = imageGallery{
            if let imageCell = cell as? ImageGalleryCollectionViewCell {
                if let url = URL(string: imageGallery.galleryContents[indexPath.item].url) {
                    imageCell.backgroundImageUrl = url
                }
            }
        }
    
        return cell
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
            let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { action in
                
                let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash.fill"), identifier: nil) { action in
                    self.showDeleteConfirmationAlert(forItemAt: indexPath)
                }
                
                let copyURL = UIAction(title: "Copy URL", image: UIImage(systemName: "square.and.arrow.up.fill"), identifier: nil) { action in
                    if let imageGallery = self.imageGallery {
                        let imageURL = imageGallery.galleryContents[indexPath.row].url
                        UIPasteboard.general.string = imageURL
                    }
                }
                
                let unfavorite = UIAction(title: "Unfavorite", image: UIImage(systemName: "heart.slash.fill"), identifier: nil) { action in
                            self.unfavoriteImage(at: indexPath)
                        }
                
                return UIMenu(title: "", image: nil, identifier: nil, children: [delete, copyURL, unfavorite])
            }
            return configuration
        }
    
    private func unfavoriteImage(at indexPath: IndexPath) {
        guard let imageGallery = self.imageGallery else { return }
        let imageContent = imageGallery.galleryContents[indexPath.row]
        
        // Update the image content and notify
        NotificationCenter.default.post(name: .updatedImageDetails, object: nil, userInfo: ["imageURL": imageContent.url, "favorite": false])
        
        // Remove the item from the collection view
        collectionView.performBatchUpdates({
            self.imageGallery?.galleryContents.remove(at: indexPath.row)
            collectionView.deleteItems(at: [indexPath])
        }, completion: nil)
    }
    
    private func showDeleteConfirmationAlert(forItemAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Delete Image", message: "Are you sure you want to delete this image?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
            self.deleteImage(at: indexPath)
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func deleteImage(at indexPath: IndexPath) {
        guard var imageGallery = self.imageGallery else { return }
        let deletedURL = imageGallery.galleryContents[indexPath.row].url
        
        // Update data source first
        imageGallery.galleryContents.remove(at: indexPath.row)
        self.imageGallery = imageGallery // Update the instance variable
        
        // Post notification
        NotificationCenter.default.post(name: .deletedImage, object: nil, userInfo: ["deletedURL": deletedURL])
        
        // Perform the collection view update
        collectionView.performBatchUpdates({
            collectionView.deleteItems(at: [indexPath])
        }, completion: nil)
        
        refreshImageCells()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //let showOrderCell = showOrder[indexPath.item]
        return CGSize(width: imageCellWidth, height: imageCellWidth * (imageGallery?.galleryContents[indexPath.item].aspectRatio ?? 1.0))
    }
    
    // Segue to show the full image in new MVC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showImage3" {
            if let imageVC = segue.destination.contents as? ImageViewController {
                if let collectionViewIndices = collectionView?.indexPathsForSelectedItems, let collectionViewIndex = collectionViewIndices.first
                {
                    //let galleryIndex = showOrder[collectionViewIndex.item]
                    self.tappedImageIndex = collectionViewIndex.item
                    if let imageGallery = imageGallery {
                        let imageGalleryContent = imageGallery.galleryContents[collectionViewIndex.item]
                        if let url = URL(string: imageGalleryContent.url) {
                            imageVC.imageURL = url
                        }
                        imageVC.imageTitle = imageGalleryContent.imageTitle
                        imageVC.stars = imageGalleryContent.stars
                        imageVC.favorite = imageGalleryContent.favorite
                        //save()
                        //self.document?.close()
                    }
                }
            }
        }
    }
    

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
