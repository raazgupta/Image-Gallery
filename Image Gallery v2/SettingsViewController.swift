//
//  SettingsViewController.swift
//  Image Gallery v2
//
//  Created by Raj Gupta on 2020/08/25.
//  Copyright © 2020 SoulfulMachine. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let font = UIFont(name: "American Typewriter", size: 18)
        let attributes = [NSAttributedString.Key.font: font]
        let aString1 = NSMutableAttributedString(string: """
        Welcome to the Image Keeper App. This app can be used to store image links from the web or image files. If you are saving images from the web, this app stores the web link instead of the image files to save disk space. This allows you to store a large number of web images without worrying about disk space.\n
        For storing web image links, start by  tapping: Create Document. On your web browser, tap and hold image until Copy option is displayed. Tap Copy. In the app,  tap on the document that you have created, tap the
        """,attributes: attributes as [NSAttributedString.Key : Any])
        
        let imageAttachment1 = NSTextAttachment()
        imageAttachment1.image = UIImage(systemName:"arrow.down.doc.fill")
        let imageString1 = NSAttributedString(attachment: imageAttachment1)
        
        aString1.append(imageString1)
        
        let aString2 = NSMutableAttributedString(string: " button to store the image. You can tap on an image Thumbnail to view the image.",attributes: attributes as [NSAttributedString.Key : Any])
        
        aString1.append(aString2)
        
        helpText.attributedText = aString1
    }
    
    @IBOutlet weak var helpText: UITextView!
    
    @IBAction func done(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
