//
//  ImageViewController.swift
//  ImageGallery
//
//  Created by Raj Gupta on 3/10/18.
//  Copyright © 2018 SoulfulMachine. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {
    
    var imageTitle: String?
    var stars: Int?
    var favorite: Bool?
    private var hasAppliedInitialZoom = false
    private var hasAppliedInitialContentOffset = false

    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.minimumZoomScale = 1/25
            scrollView.maximumZoomScale = 3.0
            scrollView.delegate = self
            scrollView.addSubview(imageView)
        }
    }
    
    var imageView = UIImageView()
    
    var imageURL: URL? {
        didSet {
            image = nil
            
            if view.window != nil {
                fetchImage()
            }
        }
    }
    
    private var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
            imageView.sizeToFit()
            scrollView?.contentSize = imageView.frame.size
            hasAppliedInitialZoom = false
            hasAppliedInitialContentOffset = false
            updateZoomScaleToFitIfNeeded()
            spinner?.stopAnimating()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if imageView.image == nil {
            fetchImage()
        }
        if let imageTitle = imageTitle {
            title = imageTitle
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateZoomScaleToFitIfNeeded()
        centerImageIfNeeded()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImageIfNeeded()
    }
    
    
    private func fetchImage() {
        if let url = imageURL {
            spinner.startAnimating()
            
            getImageFromURL(url: url, completion: { [weak self] (image) in
                if let image = image, url == self?.imageURL {
                    self?.image = image
                }
            })
            
            /*
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let urlContents = try? Data(contentsOf: url)
                DispatchQueue.main.async {
                    if let imageData = urlContents, url == self?.imageURL {
                        self?.image = UIImage(data: imageData)
                    }
                }
            }
            */
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.tintColor = #colorLiteral(red: 0.262745098, green: 0.7333333333, blue: 0.5294117647, alpha: 1)
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.262745098, green: 0.7333333333, blue: 0.5294117647, alpha: 1)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showImageDetails" {
            if let imageDetailsVC = segue.destination as? ImageDetailsViewController {
                imageDetailsVC.delegate = self
                // Pass any necessary data to the ImageDetailsViewController
                imageDetailsVC.imageTitle = imageTitle
                imageDetailsVC.stars = stars
                imageDetailsVC.favorite = favorite
                imageDetailsVC.imageURL = imageURL?.absoluteString
            }
        }
    }

    private func updateZoomScaleToFitIfNeeded() {
        guard
            !hasAppliedInitialZoom,
            let scrollView = scrollView,
            let image = imageView.image,
            scrollView.bounds.width > 0,
            scrollView.bounds.height > 0
        else { return }

        let widthScale = scrollView.bounds.width / image.size.width
        let heightScale = scrollView.bounds.height / image.size.height
        let fitScale = min(widthScale, heightScale)

        scrollView.minimumZoomScale = min(fitScale, 1.0)
        scrollView.zoomScale = fitScale
        hasAppliedInitialZoom = true
        updateInitialContentOffsetIfNeeded()
    }

    private func centerImageIfNeeded() {
        guard let scrollView = scrollView else { return }

        let horizontalInset = max((scrollView.bounds.width - imageView.frame.width) / 2, 0)
        let verticalInset = max((scrollView.bounds.height - imageView.frame.height) / 2, 0)
        scrollView.contentInset = UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset
        )
        scrollView.scrollIndicatorInsets = scrollView.contentInset
    }

    private func updateInitialContentOffsetIfNeeded() {
        guard
            !hasAppliedInitialContentOffset,
            let scrollView = scrollView
        else { return }

        centerImageIfNeeded()

        let minOffsetX = -scrollView.contentInset.left
        let minOffsetY = -scrollView.contentInset.top
        scrollView.contentOffset = CGPoint(x: minOffsetX, y: minOffsetY)
        hasAppliedInitialContentOffset = true
    }
}
