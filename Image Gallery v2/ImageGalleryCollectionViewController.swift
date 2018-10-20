//
//  ImageGalleryCollectionViewController.swift
//  ImageGallery
//
//  Created by Raj Gupta on 24/9/18.
//  Copyright © 2018 SoulfulMachine. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class ImageGalleryCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDragDelegate, UICollectionViewDropDelegate {
    
    @IBOutlet weak var imageGalleryView: UICollectionView!
    
    //var imageUrlCollection: [(url: URL, aspectRatio: CGFloat)] = []
    var imageGallery: ImageGalleryModel = ImageGalleryModel(title: "Gallery")
    
    var imageCellWidth: CGFloat = 180.0
    
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
    
    var flowLayout: UICollectionViewFlowLayout? {
        return collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        collectionView?.dragDelegate = self
        collectionView?.dropDelegate = self
        
        //imageCellWidth = (collectionView?.bounds.width)! / 2
        
        // Add button to display gallery table
        //navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        
        // When the app goes to foreground, refresh cells as some cells were showing grey otherwise
        //NotificationCenter.default.addObserver(self, selector: #selector(refreshImageCells), name: UIApplication.willEnterForegroundNotification, object: nil)
        
    }
    
    @objc func refreshImageCells() {
        for cell in collectionView.visibleCells {
            if let imageCell = cell as? ImageGalleryCollectionViewCell {
                if let indexPath = collectionView.indexPath(for: cell) {
                    imageCell.backgroundImageUrl = imageGallery.galleryContents[indexPath.item].url
                    imageCell.layoutSubviews()
                }
            }
        }
        collectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageGallery.galleryContents.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath)
    
        // Configure the cell
        if let imageCell = cell as? ImageGalleryCollectionViewCell {
            imageCell.backgroundImageUrl = imageGallery.galleryContents[indexPath.item].url
        }
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: imageCellWidth, height: imageCellWidth * imageGallery.galleryContents[indexPath.item].aspectRatio)
    }

    
    // Dragging and Dropping within Collection View
    
    // Drag
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        
            session.localContext = collectionView
            return dragItems(at: indexPath)
    }
    
    
    
    private func dragItems(at indexPath: IndexPath) -> [UIDragItem] {
        let nsUrlItem = imageGallery.galleryContents[indexPath.item].url as NSURL
        let dragItem = UIDragItem(itemProvider: NSItemProvider(object: nsUrlItem))
        dragItem.localObject = imageGallery.galleryContents[indexPath.item]
        return [dragItem]
    }
 
    
    //Drop
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSURL.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        let isSelf = (session.localDragSession?.localContext as? UICollectionView) == collectionView
        return UICollectionViewDropProposal(operation: isSelf ? .move : .copy, intent: .insertAtDestinationIndexPath)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        
            
        for item in coordinator.items {
            

            
            if let sourceIndexPath = item.sourceIndexPath {
                
                if let imageUrlCollectionItem = item.dragItem.localObject as? (url: URL, aspectRatio: CGFloat) {
                    
                    collectionView.performBatchUpdates({
                        imageGallery.galleryContents.remove(at: sourceIndexPath.item)
                        imageGallery.galleryContents.insert(imageUrlCollectionItem, at: destinationIndexPath.item)
                        collectionView.deleteItems(at: [sourceIndexPath])
                        collectionView.insertItems(at: [destinationIndexPath])
                    })
                    coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                    
                }
            }
            else {
                let placeholderContext = coordinator.drop(item.dragItem, to: UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: "DropPlaceHolderCell"))
                
                item.dragItem.itemProvider.loadObject(ofClass: NSURL.self) { (provider, error) in
                    if let url = provider as? URL {
                        
                        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                            let urlContents = try? Data(contentsOf: url.imageURL)
                            DispatchQueue.main.async {
                                if let imageData = urlContents, url == provider as? URL {
                                    if let image = UIImage(data: imageData) {
                                        placeholderContext.commitInsertion(dataSourceUpdates: { insertionIndexPath in
                                            self?.imageGallery.galleryContents.insert((url.imageURL,image.size.height/image.size.width), at: insertionIndexPath.item)
                                        })
                                    }
                                }
                                else {
                                    placeholderContext.deletePlaceholder()
                                }
                                
                            }
                        }
                    }
                }
            }
            
        }
        
    }

    // Segue to show the full image in new MVC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showImage" {
            if let imageVC = segue.destination.contents as? ImageViewController {
                if let collectionViewIndices = collectionView?.indexPathsForSelectedItems, let collectionViewIndex = collectionViewIndices.first
                {
                    let imageGalleryContent = imageGallery.galleryContents[collectionViewIndex.item]
                    imageVC.imageURL = imageGalleryContent.url
                }
            }
        }
    }
    
    // Add new collection view cell and paste image in PasteBoard
    @IBAction func addPaste(_ sender: Any) {
        //imageGallery.galleryContents.insert((URL(string: "http://www.clker.com/cliparts/3/m/v/Y/E/V/small-red-apple-md.png")!,1.0), at: 0)
        //collectionView?.insertItems(at: [IndexPath(row: 0, section: 0)])
        
        if UIPasteboard.general.hasURLs {
            if let url = UIPasteboard.general.url {
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    let urlContents = try? Data(contentsOf: url.imageURL)
                    DispatchQueue.main.async {
                        if let imageData = urlContents {
                            if let image = UIImage(data: imageData) {
                                self?.imageGallery.galleryContents.insert((url,image.size.height/image.size.width), at: 0)
                                self?.collectionView?.insertItems(at: [IndexPath(row: 0, section: 0)])
                            }
                        }
                        
                    }
                }
            }
        }
        else {
            print ("No URL")
        }
        
    }
    
    @IBAction func undoImageAdd(_ sender: Any) {
        if imageGallery.galleryContents.count > 0 {
            imageGallery.galleryContents.remove(at: 0)
            collectionView.deleteItems(at: [IndexPath(row: 0, section: 0)])
        }
    }
    
    
}
