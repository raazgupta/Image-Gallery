//
//  imageGalleryModel.swift
//  ImageGallery
//
//  Created by Raj Gupta on 2/10/18.
//  Copyright © 2018 SoulfulMachine. All rights reserved.
//

import Foundation
import UIKit

struct ImageGalleryModel: Codable {
    
    var galleryTitle: String
    var galleryContents = [galleryContent]()
    
    struct galleryContent: Codable {
        let url: URL
        let aspectRatio: CGFloat
    }
    
    init(title: String) {
        galleryTitle = title
        galleryContents = []
    }
    
    // JSON encoder and decoder
    init?(json: Data) {
        if let newValue = try? JSONDecoder().decode(ImageGalleryModel.self, from: json) {
            self = newValue
        } else {
            return nil
        }
    }
    
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
    
}
