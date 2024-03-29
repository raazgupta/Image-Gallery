//
//  DocumentBrowserViewController.swift
//  Image Gallery v2
//
//  Created by Raj Gupta on 21/10/18.
//  Copyright © 2018 SoulfulMachine. All rights reserved.
//

import UIKit


class DocumentBrowserViewController: UIDocumentBrowserViewController, UIDocumentBrowserViewControllerDelegate {
    
    var template: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        allowsDocumentCreation = true
        allowsPickingMultipleItems = false
        
        // Update the style of the UIDocumentBrowserViewController
        browserUserInterfaceStyle = .dark
        view.tintColor = #colorLiteral(red: 0.262745098, green: 0.7333333333, blue: 0.5294117647, alpha: 1)
        
        let helpButton = UIBarButtonItem(title: "Help", style: .plain, target: self, action: #selector(settingsButton(sender:)))
        additionalTrailingNavigationBarButtonItems = [helpButton]
        
        // Specify the allowed content types of your application via the Info.plist.
        
        // Do any additional setup after loading the view, typically from a nib.
        
        do {
        template = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("Untitled.json")
        } catch {
            print(error)
        }
        if template != nil {
            allowsDocumentCreation = FileManager.default.createFile(atPath: template!.path, contents: Data())
            
        }
        
    }
    
    @objc func settingsButton(sender: UIBarButtonItem){
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let settingsVC = storyBoard.instantiateViewController(withIdentifier: "settingsScreen")
        settingsVC.modalPresentationStyle = .fullScreen
        present(settingsVC, animated: true)
    }
    
    
    // MARK: UIDocumentBrowserViewControllerDelegate
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
        importHandler(template,.copy)
        
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL) {
        // Present the Document View Controller for the new newly created document
        presentDocument(at: destinationURL, isNewDocument: true)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, failedToImportDocumentAt documentURL: URL, error: Error?) {
        // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
        print("failedImport")
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentURLs documentURLs: [URL]) {
        guard let sourceURL = documentURLs.first else { return }
        
        // Present the Document View Controller for the first document that was picked.
        // If you support picking multiple items, make sure you handle them all.
        presentDocument(at: sourceURL)
    }
    
    // MARK: Document Presentation
    
    func presentDocument(at documentURL: URL, isNewDocument: Bool = false) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let pathExt = documentURL.pathExtension
        //let uti: String? = (try? documentURL.resourceValues(forKeys: [.typeIdentifierKey]))?.typeIdentifier
        
        if pathExt == "json" {
            let documentVC = storyBoard.instantiateViewController(withIdentifier: "DocumentMVC")
            if let imageGalleryCollectionViewController = documentVC.contents as? ImageGalleryCollectionViewController {
                imageGalleryCollectionViewController.document = ImageGalleryDocument(fileURL: documentURL)
                imageGalleryCollectionViewController.isNewDocument = isNewDocument
            }
            documentVC.modalPresentationStyle = .fullScreen
            present(documentVC, animated: true)
        }
        
        if (pathExt == "jpeg" || pathExt == "png"){
            let imageDocumentVC = storyBoard.instantiateViewController(withIdentifier: "ImageDocumentMVC")
            if let imageViewController = imageDocumentVC.contents as? ImageViewController2 {
                imageViewController.document = ImageDocument(fileURL: documentURL)
            }
            imageDocumentVC.modalPresentationStyle = .fullScreen
            present(imageDocumentVC, animated: true)
        }
 
    }
}

