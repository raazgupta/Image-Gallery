//
//  RandomImageGalleryCollectionViewController.swift
//  Image Gallery v2
//
//  Created by Raj Gupta on 2020/08/29.
//  Copyright © 2020 SoulfulMachine. All rights reserved.
//

import UIKit

private let reuseIdentifier = "ImageCell"

class RandomImageGalleryCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var tappedImageIndex: Int?
    
    var imageGallery: ImageGalleryModel?
    var showOrder: [Int]?
    var imageCellWidth: CGFloat = 180.0
    var flowLayout: UICollectionViewFlowLayout? {
        return collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    
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
        if let showOrder = showOrder {
            return showOrder.count
        }
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell2", for: indexPath)
        
        // Configure the cell
        if let imageGallery = imageGallery, let showOrder = showOrder {
            let showOrderCell = showOrder[indexPath.item]
            if let imageCell = cell as? ImageGalleryCollectionViewCell {
                if let url = URL(string: imageGallery.galleryContents[showOrderCell].url) {
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
                if let imageGallery = self.imageGallery, let showOrder = self.showOrder {
                    if imageGallery.galleryContents.count > 0 {
                        
                        let deletedURL = self.imageGallery?.galleryContents[indexPath.row].url
                        NotificationCenter.default.post(name: .deletedImage, object: nil, userInfo: ["deletedURL": deletedURL! ])
                        
                        let showIndex = showOrder[indexPath.row]
                        self.imageGallery!.galleryContents.remove(at: showIndex)
                        //let showItemToDelete = self.showOrder![showIndex]
                        self.showOrder!.remove(at: indexPath.row)
                        for i in 0..<self.showOrder!.count {
                            if self.showOrder![i] > showIndex{
                                self.showOrder![i] = self.showOrder![i] - 1
                            }
                        }
                        collectionView.deleteItems(at: [indexPath])
                        
                        self.refreshImageCells()
                    }
                }
            })
            
            
            // Press image to copy URL
            let copyURL = UIAction(title: "Copy", image: UIImage(systemName: "square.and.arrow.up.fill"), identifier: nil, handler: { action in
                if let imageGallery = self.imageGallery, let showOrder = self.showOrder {
                    if imageGallery.galleryContents.count > 0 {
                        let showIndex = showOrder[indexPath.row]
                        let imageURL = imageGallery.galleryContents[showIndex].url
                        
                        UIPasteboard.general.string = imageURL
                    }
                }
            })
            
            return UIMenu(title: "", image: nil, identifier: nil, children: [copyURL, delete])
        }
        return configuration
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let showOrder = showOrder, let imageGallery = imageGallery {
            let showOrderCell = showOrder[indexPath.item]
            return CGSize(width: imageCellWidth, height: imageCellWidth * imageGallery.galleryContents[showOrderCell].aspectRatio)
        }
        return CGSize(width: imageCellWidth, height: imageCellWidth)
    }
    
    // Segue to show the full image in new MVC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showImage2" {
            if let imageVC = segue.destination.contents as? ImageViewController {
                
                if let collectionViewIndices = collectionView?.indexPathsForSelectedItems, let collectionViewIndex = collectionViewIndices.first
                {
                    if let showOrder = showOrder, let imageGallery = imageGallery {
                        self.tappedImageIndex = collectionViewIndex.item
                        let galleryIndex = showOrder[collectionViewIndex.item]
                        let imageGalleryContent = imageGallery.galleryContents[galleryIndex]
                        if let url = URL(string: imageGalleryContent.url) {
                            imageVC.imageURL = url
                        }
                        imageVC.imageTitle = imageGalleryContent.imageTitle
                        imageVC.stars = imageGalleryContent.stars
                        imageVC.favorite = imageGalleryContent.favorite
                    }

                }
            }
        }
    }
    
    @IBAction func shuffle(_ sender: UIBarButtonItem) {
        showOrder = imageGallery?.determineShowOrder(random: true)
        refreshImageCells()
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
