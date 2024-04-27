//
//  ImageGalleryCollectionViewController.swift
//  ImageGallery
//
//  Created by Raj Gupta on 24/9/18.
//  Copyright © 2018 SoulfulMachine. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class ImageGalleryCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDragDelegate, UICollectionViewDropDelegate, SecurityOptionsViewControllerDelegate, EnterPasswordViewContollerDelegate {
    
    // Doing Document Browser View Controller things
    
    // Converting from JSON document to ImageGalleryModel
    var document: ImageGalleryDocument?
    var galleryPW: String?
    var galleryEN: Bool?
    var showImages: Bool = false
    var showEnterPassword: Bool = true
    //var isImageGalleryDecrypted = false
    var isImageGalleryEncrypted = false
    var isDocumentOpen = false
    var isNewDocument = false
    
    var tappedImageIndex: Int?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !isDocumentOpen {
            document?.open { success in
                if success {
                    self.isDocumentOpen = true
                    self.imageGallery.galleryTitle = self.document?.localizedName ?? "Gallery"
                    
                    let currentImageGallery = self.document?.imageGallery
                    if let imageGallery = currentImageGallery {
                        self.imageGallery = imageGallery
                        
                        // Check if starProbabilityValues is nil and initialize it if so
                        if self.imageGallery.starProbabilityValues == nil {
                            self.imageGallery.starProbabilityValues = ImageGalleryModel.starProbabilities(star1: 60, star2: 30, star3: 10)
                        }
                        
                        if self.imageGallery.galleryPW != "" && self.imageGallery.galleryEN == true {
                            self.galleryPW = self.imageGallery.galleryPW
                            self.galleryEN = self.imageGallery.galleryEN
                            self.galleryEN = self.decrypt()
                        }
                        
                        if self.imageGallery.galleryPW != "" {
                            
                            if self.showEnterPassword {
                                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                                let enterPasswordVC = storyBoard.instantiateViewController(withIdentifier: "enterPassword") as! EnterPasswordViewController
                                enterPasswordVC.delegate = self
                                enterPasswordVC.correctPassword = self.imageGallery.galleryPW
                                enterPasswordVC.modalPresentationStyle = .fullScreen
                                self.present(enterPasswordVC,animated: true)
                            }
                        }
                        else {
                            self.showImages = true
                        }
                    }
                    else {
                        if self.isNewDocument {
                            self.imageGallery = ImageGalleryModel(title: "Gallery")
                            self.showImages = true
                        }
                        else {
                            let alert = UIAlertController(title: "Unable to read file", message: "The app is unable to read this file format", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "I will try again another way!", style: .default, handler: {(alert: UIAlertAction!) in
                                self.dismiss(animated: true)
                            }))
                            self.present(alert, animated: true)
                        
                        }
                    }
                    
                    
                    
                }
            }
        }
        
        if self.showEnterPassword == false && self.showImages == false {
            self.dismiss(animated: true)
        }
        /*
        else if self.showImages == true {
            self.showOrder = self.imageGallery.determineShowOrder(random: false)
            //self.refreshImageCells()
        }
         */
    }
    
    func passwordResult(showImages: Bool, showEnterPassword: Bool) {
        self.showImages = showImages
        self.showEnterPassword = showEnterPassword
        /*
        if showImages == true {
            showOrder = imageGallery.determineShowOrder(random: false)
        }
         */
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Refresh image cells after view has appeared
        refreshImageCells()
        
    }
    
    @IBAction func save() {
        
        var enImageGallery: ImageGalleryModel?
        if let galleryPW = galleryPW {
            imageGallery.galleryPW = galleryPW
        }
        if let galleryEN = galleryEN, let _ = galleryPW {
            imageGallery.galleryEN = galleryEN
            if galleryEN == true {
                enImageGallery = encrypt()
                document?.imageGallery = enImageGallery
            }
            else {
                document?.imageGallery = imageGallery
            }
        }
        else {
            document?.imageGallery = imageGallery
        }
        
        if document?.imageGallery != nil {
            document?.updateChangeCount(.done)
        }
    }
    
    @IBAction func close(_ sender: UIBarButtonItem) {

        save()
        dismiss(animated: true) {
            self.document?.close()
        }
    }
    
    private func encrypt() -> ImageGalleryModel?{
        
        //if !isImageGalleryEncrypted {
            var newImageGallery = ImageGalleryModel(title: "Gallery")
            newImageGallery.galleryPW = galleryPW!
            newImageGallery.galleryEN = galleryEN!
            newImageGallery.starProbabilityValues?.star1 = imageGallery.starProbabilityValues?.star1 ?? 60.0
            newImageGallery.starProbabilityValues?.star2 = imageGallery.starProbabilityValues?.star2 ?? 30.0
            newImageGallery.starProbabilityValues?.star3 = imageGallery.starProbabilityValues?.star3 ?? 10.0
            
            for galleryContent in imageGallery.galleryContents {
                let pwLength = UInt32(galleryPW!.count)
                var enUrlString = ""
                // encrypt the url
                for character in galleryContent.url {
                    guard let uniCode = UnicodeScalar(String(character)) else {
                        return nil
                    }
                    guard let newUniCode = UnicodeScalar(uniCode.value+pwLength) else {
                        return nil
                    }
                    enUrlString.append(String(newUniCode))
                    /*
                    switch uniCode {
                    case "A"..<"Z","a"..<"z":
                        enUrlString.append(String(UnicodeScalar(uniCode.value+pwLength)!))
                    default:
                        enUrlString.append(character)
                    }
                     */
                }
                
                // encrypt the title
                var enTitleString = ""
                if let imageTitle = galleryContent.imageTitle {
                    for character in imageTitle {
                        guard let uniCode = UnicodeScalar(String(character)) else {
                            return nil
                        }
                        guard let newUniCode = UnicodeScalar(uniCode.value+pwLength) else {
                            return nil
                        }
                        enTitleString.append(String(newUniCode))
                        /*
                         switch uniCode {
                         case "A"..<"Z","a"..<"z":
                         enUrlString.append(String(UnicodeScalar(uniCode.value+pwLength)!))
                         default:
                         enUrlString.append(character)
                         }
                         */
                    }
                }
                
                
                let newGalleryContent = ImageGalleryModel.galleryContent(url: enUrlString, aspectRatio: galleryContent.aspectRatio, imageTitle: enTitleString, stars: galleryContent.stars, favorite: galleryContent.favorite )
                newImageGallery.galleryContents.append(newGalleryContent)
            }
            //imageGallery = newImageGallery
            //isImageGalleryEncrypted = true
        //}
        return newImageGallery
    }
    
    private func decrypt() -> Bool {
        //if !isImageGalleryDecrypted {
            var newImageGallery = ImageGalleryModel(title: "Gallery")
            newImageGallery.galleryPW = galleryPW!
            newImageGallery.galleryEN = galleryEN!
            newImageGallery.starProbabilityValues?.star1 = imageGallery.starProbabilityValues?.star1 ?? 60.0
            newImageGallery.starProbabilityValues?.star2 = imageGallery.starProbabilityValues?.star2 ?? 30.0
            newImageGallery.starProbabilityValues?.star3 = imageGallery.starProbabilityValues?.star3 ?? 10.0
            
            for galleryContent in imageGallery.galleryContents {
                let pwLength = UInt32(galleryPW!.count)
                
                // decrypt the url
                var deUrlString = ""
                for character in galleryContent.url {
                    guard let uniCode = UnicodeScalar(String(character)) else {
                        return false
                    }
                    guard let newUniCode = UnicodeScalar(uniCode.value-pwLength) else {
                        return false
                    }
                    deUrlString.append(String(newUniCode))
                    /*
                    switch uniCode {
                    case "A"..<"Z","a"..<"z":
                        enUrlString.append(String(UnicodeScalar(uniCode.value+pwLength)!))
                    default:
                        enUrlString.append(character)
                    }
                     */
                }
                
                //decrypt the title
                var deTitleString = ""
                if let imageTitle = galleryContent.imageTitle {
                    for character in imageTitle {
                        guard let uniCode = UnicodeScalar(String(character)) else {
                            return false
                        }
                        guard let newUniCode = UnicodeScalar(uniCode.value-pwLength) else {
                            return false
                        }
                        deTitleString.append(String(newUniCode))
                        /*
                         switch uniCode {
                         case "A"..<"Z","a"..<"z":
                         enUrlString.append(String(UnicodeScalar(uniCode.value+pwLength)!))
                         default:
                         enUrlString.append(character)
                         }
                         */
                    }
                }
                
                let newGalleryContent = ImageGalleryModel.galleryContent(url: deUrlString, aspectRatio: galleryContent.aspectRatio, imageTitle: deTitleString, stars: galleryContent.stars, favorite: galleryContent.favorite)
                newImageGallery.galleryContents.append(newGalleryContent)
            }
            imageGallery = newImageGallery
            //isImageGalleryDecrypted = true
        //}
        return true
    }
    
    // Doing Collection View things
    
    @IBOutlet weak var imageGalleryView: UICollectionView!
    
    //var imageUrlCollection: [(url: URL, aspectRatio: CGFloat)] = []
    var imageGallery: ImageGalleryModel = ImageGalleryModel(title: "Gallery")
    //var showOrder: [Int] = []
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
        
        // Enble dragging on iphone
        collectionView?.dragInteractionEnabled = true
        
        self.collectionView.refreshControl = UIRefreshControl()
        self.collectionView.refreshControl?.addTarget(self, action: #selector(pasteLink), for: .valueChanged)
        
        view.tintColor = #colorLiteral(red: 0.262745098, green: 0.7333333333, blue: 0.5294117647, alpha: 1)
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.262745098, green: 0.7333333333, blue: 0.5294117647, alpha: 1)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleDeletedImage), name: .deletedImage, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdatedImageDetails), name: .updatedImageDetails, object: nil)
        
        //imageCellWidth = (collectionView?.bounds.width)! / 2
        
        // Add button to display gallery table
        //navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        
        // When the app goes to foreground, refresh cells as some cells were showing grey otherwise
        //NotificationCenter.default.addObserver(self, selector: #selector(refreshImageCells), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        
    }
    
    @objc func handleDeletedImage(notification: Notification) {
        if let deletedImageURL = notification.userInfo?["deletedURL"] {
            imageGallery.deleteGalleryContent(byURL: deletedImageURL as! String)
        }
    }
    
    @objc func handleUpdatedImageDetails(notification: Notification) {
        if let imageURL = notification.userInfo?["imageURL"] {
            let imageTitle = notification.userInfo?["imageTitle"]
            let stars = notification.userInfo?["stars"]
            let favorite = notification.userInfo?["favorite"]
            imageGallery.updateGalleryContent(byURL: imageURL as! String, newTitle: imageTitle as? String, newStars: stars as? Int, newFavorite: favorite as? Bool)
        }
    }
    
    @objc func refreshImageCells() {
        /*
        for cell in collectionView.visibleCells {
            if let imageCell = cell as? ImageGalleryCollectionViewCell {
                if let indexPath = collectionView.indexPath(for: cell) {
                    imageCell.backgroundImageUrl = imageGallery.galleryContents[indexPath.item].url
                    imageCell.layoutSubviews()
                }
            }
        }
        */
        collectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if showImages {
            return imageGallery.galleryContents.count
        }
        else {
            return 0
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath)
        //let showOrderCell = showOrder[indexPath.item]
        
        // Configure the cell
        if let imageCell = cell as? ImageGalleryCollectionViewCell {
            if let url = URL(string: imageGallery.galleryContents[indexPath.item].url) {
                imageCell.backgroundImageUrl = url
            }
        }
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil){ action in
            
            // Press image to delete
            let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash.fill"), identifier: nil, handler: {action in
                if self.imageGallery.galleryContents.count > 0 {
                    //let showIndex = self.showOrder[indexPath.row]
                    self.imageGallery.galleryContents.remove(at: indexPath.row)
                    //self.showOrder = self.imageGallery.determineShowOrder()
                    collectionView.deleteItems(at: [indexPath])
                    //self.save()
                    self.refreshImageCells()
                }
            })
            
            // Press image to copy URL
            let copyURL = UIAction(title: "Copy", image: UIImage(systemName: "square.and.arrow.up.fill"), identifier: nil, handler: { action in
                if self.imageGallery.galleryContents.count > 0 {
                    //let showIndex = self.showOrder[indexPath.row]
                    let imageURL = self.imageGallery.galleryContents[indexPath.row].url
                    
                    UIPasteboard.general.string = imageURL
                }
            })
            
            return UIMenu(title: "", image: nil, identifier: nil, children: [delete, copyURL])
        }
        return configuration
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //let showOrderCell = showOrder[indexPath.item]
        return CGSize(width: imageCellWidth, height: imageCellWidth * imageGallery.galleryContents[indexPath.item].aspectRatio)
    }

    
    // Dragging and Dropping within Collection View
    
    // Drag
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        
            session.localContext = collectionView
            return dragItems(at: indexPath)
    }
    
    
    
    private func dragItems(at indexPath: IndexPath) -> [UIDragItem] {
        let nsUrlItem = imageGallery.galleryContents[indexPath.item].url as NSString
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
                
                if let imageUrlCollectionItem = item.dragItem.localObject as? ImageGalleryModel.galleryContent {
                    
                    collectionView.performBatchUpdates({
                        print("Performing Source Batch")
                        imageGallery.galleryContents.remove(at: sourceIndexPath.item)
                        imageGallery.galleryContents.insert(imageUrlCollectionItem, at: destinationIndexPath.item)
                        collectionView.deleteItems(at: [sourceIndexPath])
                        collectionView.insertItems(at: [destinationIndexPath])
                        //save()
                    })
                    coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                    
                }
            }
            else {
                let placeholderContext = coordinator.drop(item.dragItem, to: UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: "DropPlaceHolderCell"))
                
                item.dragItem.itemProvider.loadObject(ofClass: NSString.self) { (provider, error) in
                    if let urlString = provider as? String {
                        if let url = URL(string: urlString){
                            getImageFromURL(url: url, completion: {[weak self] (image) in
                                if let image = image {
                                    placeholderContext.commitInsertion(dataSourceUpdates: { insertionIndexPath in
                                        self?.imageGallery.galleryContents.insert(ImageGalleryModel.galleryContent(url: urlString, aspectRatio: image.size.height/image.size.width, imageTitle: nil, stars: nil, favorite: nil), at: insertionIndexPath.item)
                                        //self?.save()
                                    })
                                }
                                else {
                                    placeholderContext.deletePlaceholder()
                                }
                            })
                        }
                        /*
                        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                            let urlContents = try? Data(contentsOf: url.imageURL)
                            DispatchQueue.main.async {
                                if let imageData = urlContents, url == provider as? URL {
                                    if let image = UIImage(data: imageData) {
                                        placeholderContext.commitInsertion(dataSourceUpdates: { insertionIndexPath in
                                            //(url.imageURL,image.size.height/image.size.width)
                                            self?.imageGallery.galleryContents.insert(ImageGalleryModel.galleryContent(url: url.imageURL, aspectRatio: image.size.height/image.size.width) , at: insertionIndexPath.item)
                                        })
                                    }
                                }
                                else {
                                    placeholderContext.deletePlaceholder()
                                }
                                
                            }
                        }
                        */
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
                    //let galleryIndex = showOrder[collectionViewIndex.item]
                    self.tappedImageIndex = collectionViewIndex.item
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
        if segue.identifier == "showSecurityOptions" {
            let securityVC = segue.destination as! SecurityOptionsViewController
            securityVC.delegate = self
            securityVC.star1Probability = imageGallery.starProbabilityValues?.star1 ?? 60.0
            securityVC.star2Probability = imageGallery.starProbabilityValues?.star2 ?? 30.0
            securityVC.star3Probability = imageGallery.starProbabilityValues?.star3 ?? 10.0
            securityVC.galleryPW = imageGallery.galleryPW
            securityVC.galleryEN = imageGallery.galleryEN
            //save()
            //self.document?.close()
        }
        if segue.identifier == "shuffleImages" {
            let randomVC = segue.destination as! RandomImageGalleryCollectionViewController
            randomVC.imageGallery = imageGallery
            randomVC.showOrder = imageGallery.determineShowOrder(random: true)
        }
        if segue.identifier == "showSearch" {
            if let searchVC = segue.destination.contents as? ImageSearchViewController {
                searchVC.imageGallery = imageGallery
            }
        }
        if segue.identifier == "showGachaImage" {
            if let imageVC = segue.destination.contents as? ImageViewController {
                
                let imageGalleryContent = gachaGallery()
                
                if let imageGalleryContent = imageGalleryContent {
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
    
    private func gachaGallery() -> ImageGalleryModel.galleryContent? {
        // Ensure there are images in the gallery
        guard !imageGallery.galleryContents.isEmpty else { return nil }

        // Extract star probabilities
        let star1Probability = Double (imageGallery.starProbabilityValues?.star1 ?? 60.0)
        let star2Probability = Double (imageGallery.starProbabilityValues?.star2 ?? 30.0)

        // Randomly pick a star level based on probabilities
        let randomNumber = Double.random(in: 0..<100)
        let starLevel: Int
        if randomNumber < star1Probability {
            starLevel = 1
        } else if randomNumber < star1Probability + star2Probability {
            starLevel = 2
        } else {
            starLevel = 3
        }

        // Filter images by the chosen star level
        let filteredImages = imageGallery.galleryContents.filter { $0.stars == starLevel }

        // If no images at this star level, or if there's a logic error, default to all images
        let imagesToChooseFrom = filteredImages.isEmpty ? imageGallery.galleryContents : filteredImages

        // Pick a random image from the set
        return imagesToChooseFrom.randomElement()
    }

    
    func doSomethingWith(pwSwitch: Bool, pw: String, isEN: Bool, star1Probability: Float, star2Probability: Float, star3Probability: Float) {
        if pwSwitch {
            galleryPW = pw
        }
        else {
            galleryPW = ""
        }
        galleryEN = isEN
        imageGallery.starProbabilityValues?.star1 = star1Probability
        imageGallery.starProbabilityValues?.star2 = star2Probability
        imageGallery.starProbabilityValues?.star3 = star3Probability
        save()
    }
    
    // Add new collection view cell and paste image in PasteBoard
    @IBAction func addPaste(_ sender: Any) {
        pasteLink()
    }
    
    /*
    @objc private func pasteLink() {
        if UIPasteboard.general.hasURLs {
            if let url = UIPasteboard.general.url {
                
                getImageFromURL(url: url, completion: { [weak self] (image) in
                    
                    defer {
                        DispatchQueue.main.async {
                            self?.collectionView.refreshControl?.endRefreshing()
                        }
                    }
                    
                    if let image = image {
                        self?.imageGallery.galleryContents.insert(ImageGalleryModel.galleryContent(url: url.absoluteString,aspectRatio: image.size.height/image.size.width, imageTitle: nil), at: 0)
                        //self?.showOrder.insert(0, at: 0)
                        self?.collectionView?.insertItems(at: [IndexPath(row: 0, section: 0)])
                        self?.save()
                        self?.refreshImageCells()
                    }
                    else {
                        print("Not an image")
                        self?.presentBadWarning()
                    }
                })
                    
            
                    /*
                    let urlContents = try? Data(contentsOf: url.imageURL)
                    DispatchQueue.main.async {
                        if let imageData = urlContents {
                            if let image = UIImage(data: imageData) {
                                //(url,image.size.height/image.size.width)
                                self?.imageGallery.galleryContents.insert(ImageGalleryModel.galleryContent(url: url,aspectRatio: image.size.height/image.size.width), at: 0)
                                self?.collectionView?.insertItems(at: [IndexPath(row: 0, section: 0)])
                            }
                        }
                        
                    }
                    */
                
            }
        }
        else {
            print ("No URL")
            presentBadWarning()
            DispatchQueue.main.async {
                self.collectionView.refreshControl?.endRefreshing()
            }
        }
        
        DispatchQueue.main.async {
            self.collectionView.refreshControl?.endRefreshing()
        }
        
    }
    */
    
    @objc private func pasteLink() {
        if UIPasteboard.general.hasURLs {
            if let url = UIPasteboard.general.url {
                getImageFromURL(url: url, completion: { [weak self] (image) in
                    DispatchQueue.main.async {
                        self?.collectionView.refreshControl?.endRefreshing()

                        if let image = image {
                            self?.imageGallery.galleryContents.insert(ImageGalleryModel.galleryContent(url: url.absoluteString, aspectRatio: image.size.height/image.size.width, imageTitle: nil, stars: nil, favorite: nil), at: 0)
                            self?.collectionView?.insertItems(at: [IndexPath(row: 0, section: 0)])
                            self?.save()
                            self?.refreshImageCells()
                        } else {
                            print("Not an image")
                            self?.presentBadWarningAfterDelay()
                        }
                    }
                })
            }
        } else {
            print("No URL")
            DispatchQueue.main.async {
                self.collectionView.refreshControl?.endRefreshing()
                self.presentBadWarningAfterDelay()
            }
        }
    }

    private func presentBadWarningAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.presentBadWarning()
        }
    }

    
    private func presentBadWarning() {
        let alert = UIAlertController(title: "Image transfer failed", message: "Unable to get Image from URL. Close this view, tap and hold until you see the Paste option.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        
        present(alert, animated: true)
    }
    
    @IBAction func undoImageAdd(_ sender: Any) {
        if imageGallery.galleryContents.count > 0 {
            //let showIndex = showOrder[0]
            imageGallery.galleryContents.remove(at: 0)
            //showOrder = imageGallery.determineShowOrder()
            collectionView.deleteItems(at: [IndexPath(row: 0, section: 0)])
            //save()
            refreshImageCells()
        }
    }

    
    
}

extension Notification.Name {
    static let deletedImage = Notification.Name("deletedImage")
    static let updatedImageDetails = Notification.Name("updatedImageDetails")
}


