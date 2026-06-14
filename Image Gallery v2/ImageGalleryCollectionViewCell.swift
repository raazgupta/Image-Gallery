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
    var isFavorited: Bool = false {
        didSet {
            updateAppearance()
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageCellSpinner: UIActivityIndicatorView!

    override var isSelected: Bool {
        didSet {
            updateAppearance()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        layer.cornerRadius = 16
        layer.masksToBounds = false
        layer.shadowOffset = .zero
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = .secondarySystemBackground
        imageView.layer.cornerRadius = 14
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        updateAppearance()
    }
    
    override func draw(_ rect: CGRect) {
        
        imageView.image = nil
        
        if let url = backgroundImageUrl {
            
            getImageFromURL(url: url, completion: { [weak self] (image) in
                    if let image = image, url == self?.backgroundImageUrl {
                        self?.imageView.image = image
                        self?.imageView.sizeThatFits((self?.bounds.size)!)
                        self?.imageCellSpinner.stopAnimating()
                    }
                })
            
            
            /*
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
            */
        }
    }

    private func updateAppearance() {
        if isSelected {
            layer.borderWidth = 4
            layer.borderColor = UIColor.systemTeal.cgColor
            layer.shadowColor = UIColor.systemTeal.withAlphaComponent(0.45).cgColor
            layer.shadowOpacity = 1
            layer.shadowRadius = 14
            layer.shadowOffset = .zero
            return
        }

        if isFavorited {
            layer.borderWidth = 4
            layer.borderColor = UIColor(red: 0.53, green: 0.32, blue: 0.93, alpha: 1).cgColor
            layer.shadowColor = UIColor(red: 0.56, green: 0.36, blue: 0.96, alpha: 0.78).cgColor
            layer.shadowOpacity = 1
            layer.shadowRadius = 18
            layer.shadowOffset = .zero
            return
        }

        layer.borderWidth = 0
        layer.borderColor = UIColor.clear.cgColor
        layer.shadowOpacity = 0
    }
    
}
