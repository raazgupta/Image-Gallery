//
//  imageGalleryModel.swift
//  ImageGallery
//
//  Created by Raj Gupta on 2/10/18.
//  Copyright © 2018 SoulfulMachine. All rights reserved.
//

import Foundation
import UIKit

class ImageGalleryModel {
    
    var galleryTitle: String
    var galleryContents: [(url: URL, aspectRatio: CGFloat)]
    
    init(title: String) {
        galleryTitle = title
        galleryContents = []
    }
    
}
