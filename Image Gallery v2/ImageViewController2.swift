//
//  ImageViewController.swift
//  ImageGallery
//
//  Created by Raj Gupta on 3/10/18.
//  Copyright © 2018 SoulfulMachine. All rights reserved.
//


// DO NOT DELETE THIS FILE. IT IS USED TO SHOW IMAGES THAT HAVE EXTENSION PNG AND JPEG

import UIKit

class ImageViewController2: UIViewController, UIScrollViewDelegate {

    var document: ImageDocument?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        document?.open { success in
            if success {
                if self.document?.fileType == "public.png" || self.document?.fileType == "public.jpeg" {
                    self.image = UIImage(data: (self.document?.fileData)!)
                }
            }
        }
    }
    
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
    
    /*
    var imageURL: URL? {
        didSet {
            image = nil
            
            if view.window != nil {
                fetchImage()
            }
        }
    }
 */
    
    private var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
            imageView.sizeToFit()
            scrollView?.contentSize = imageView.frame.size
            spinner?.stopAnimating()
        }
    }
    
    /*
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if imageView.image == nil {
            fetchImage()
        }
    }
 */
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    /*
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
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.tintColor = #colorLiteral(red: 0.262745098, green: 0.7333333333, blue: 0.5294117647, alpha: 1)
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.262745098, green: 0.7333333333, blue: 0.5294117647, alpha: 1)
    }
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true)
    }
    
    
}
