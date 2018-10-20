//
//  ImageGalleryCollectionViewCell.swift
//  ImageGallery
//
//  Created by Raj Gupta on 24/9/18.
//  Copyright © 2018 SoulfulMachine. All rights reserved.
//

import UIKit

class ImageGalleryCollectionViewCell: UICollectionViewCell {
    
    var backgroundImageUrl: URL? { didSet { setNeedsDisplay() }}
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageCellSpinner: UIActivityIndicatorView!
    
    override func draw(_ rect: CGRect) {
        
        imageView.image = nil
        
        if let url = backgroundImageUrl {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let urlContents = try? Data(contentsOf: url)
                DispatchQueue.main.async {
                    if let imageData = urlContents, url == self?.backgroundImageUrl {
                        if let backGroundImage = UIImage(data: imageData) {
                            self?.imageView.image = backGroundImage
                            self?.imageView.sizeThatFits((self?.bounds.size)!)
                            self?.imageCellSpinner.stopAnimating()
                        }
                    }
                }
            }
        }
    }
    
}
