//
//  ImageDocument.swift
//  Image Gallery v2
//
//  Created by Raj Gupta on 2020/08/24.
//  Copyright © 2020 SoulfulMachine. All rights reserved.
//

import UIKit

class ImageDocument: UIDocument {
    var fileData: Data?
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        if let fileContents = contents as? Data {
            fileData = fileContents
        }
    }
}
