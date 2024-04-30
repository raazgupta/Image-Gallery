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
    var galleryPWEN: Bool?
    var galleryEN: Bool
    var galleryContents = [galleryContent]()
    var starProbabilityValues: starProbabilities?
    
    struct galleryContent: Codable {
        let url: String
        let aspectRatio: CGFloat
        var imageTitle: String? // Optional
        var stars: Int?
        var favorite: Bool?
    }
    
    struct starProbabilities: Codable {
        var star1: Float
        var star2: Float
        var star3: Float
    }
    
    init(title: String) {
        galleryTitle = title
        galleryPW = ""
        galleryPWEN = false
        galleryEN = false
        galleryContents = []
        starProbabilityValues = starProbabilities(star1: 60.0, star2: 30.0, star3: 10.0)
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
    
    // Function to delete a galleryContent based on URL
    mutating func deleteGalleryContent(byURL url: String) {
        galleryContents.removeAll { $0.url == url }
    }
    
    mutating func updateGalleryContent(byURL url: String, newTitle: String?, newStars: Int?, newFavorite: Bool?) {
        // Iterate over all galleryContents and update items that match the URL
        for i in 0..<galleryContents.count {
            if galleryContents[i].url == url {
                galleryContents[i].imageTitle = newTitle
                galleryContents[i].stars = newStars
                galleryContents[i].favorite = newFavorite
            }
        }
    }
    
}
