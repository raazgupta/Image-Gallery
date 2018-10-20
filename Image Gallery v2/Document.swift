//
//  Document.swift
//  Image Gallery v2
//
//  Created by Raj Gupta on 21/10/18.
//  Copyright © 2018 SoulfulMachine. All rights reserved.
//

import UIKit

class Document: UIDocument {
    
    override func contents(forType typeName: String) throws -> Any {
        // Encode your document with an instance of NSData or NSFileWrapper
        return Data()
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        // Load your document from contents
    }
}

