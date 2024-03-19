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
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil){ action in
            
            // Press image to delete
            let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash.fill"), identifier: nil, handler: {action in
                if (self.imageGallery?.galleryContents.count)! > 0 {
                    //let showIndex = self.showOrder[indexPath.row]
                    let deletedURL = self.imageGallery?.galleryContents[indexPath.row].url
                    NotificationCenter.default.post(name: .deletedImage, object: nil, userInfo: ["deletedURL": deletedURL! ])
                    self.imageGallery?.galleryContents.remove(at: indexPath.row)
                    //self.showOrder = self.imageGallery.determineShowOrder()
                    collectionView.deleteItems(at: [indexPath])
                    //self.save()
                    self.refreshImageCells()
                }
            })
            
            // Press image to copy URL
            let copyURL = UIAction(title: "Copy", image: UIImage(systemName: "square.and.arrow.up.fill"), identifier: nil, handler: { action in
                if (self.imageGallery?.galleryContents.count)! > 0 {
                    //let showIndex = self.showOrder[indexPath.row]
                    let imageURL = self.imageGallery?.galleryContents[indexPath.row].url
                    
                    UIPasteboard.general.string = imageURL
                }
            })
            
            return UIMenu(title: "", image: nil, identifier: nil, children: [delete, copyURL])
        }
        return configuration
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
