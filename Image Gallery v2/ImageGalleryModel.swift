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
    var galleryPW: String
    var galleryEN: Bool
    var galleryContents = [galleryContent]()
    
    struct galleryContent: Codable {
        let url: String
        let aspectRatio: CGFloat
        let imageTitle: String? // Optional
        let stars: Int?
        let favorite: Bool?
    }
    
    init(title: String) {
        galleryTitle = title
        galleryPW = ""
        galleryEN = false
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
    
    func determineShowOrder(random:Bool=false) -> [Int]{
        let galleryCount = galleryContents.count
        var showOrder = [Int]()
        var randomOrder = [Int]()
        
        for i in 0..<galleryCount {
            showOrder.append(i)
        }
        
        if random {
            while showOrder.count > 0 {
                let showOrderCount = showOrder.count
                let randomIndex = Int.random(in: 0..<showOrderCount)
                randomOrder.append(showOrder.remove(at: randomIndex))
            }
            return randomOrder
        }
        else {
            return showOrder
        }
    }
    
}
