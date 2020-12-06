//
//  SettingsViewController.swift
//  Image Gallery v2
//
//  Created by Raj Gupta on 2020/08/25.
//  Copyright © 2020 SoulfulMachine. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Round the corners
        helpText.layer.masksToBounds = true
        helpText.layer.cornerRadius = 10.0
        helpText.textContainerInset = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        doneButton.layer.cornerRadius = 10.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let font = UIFont(name: "American Typewriter", size: 18)
        let attributes = [NSAttributedString.Key.font: font]
        let aString1 = NSMutableAttributedString(string: """
        Welcome to the Image Keeper App. This app can be used to store image links from the web or image files. If you are saving an image from the web, this app provides the option to store the web link instead of the image file to save disk space. This allows you to store a large number of web images without worrying about disk space.\n
        For storing web image links, start by  tapping: Create Document. On your web browser, tap and hold image until Copy option is displayed. Tap Copy. In the app,  tap on the document that you have created, tap the
        """,attributes: attributes as [NSAttributedString.Key : Any])
        
        let imageAttachment1 = NSTextAttachment()
        imageAttachment1.image = UIImage(systemName:"arrow.down.doc.fill")
        let imageString1 = NSAttributedString(attachment: imageAttachment1)
        aString1.append(imageString1)
        
        let aString2 = NSMutableAttributedString(string: " button to store the image. You can tap on an image Thumbnail to view the image.\n",attributes: attributes as [NSAttributedString.Key : Any])
        aString1.append(aString2)
        
        let aString5 = NSMutableAttributedString(string: "Another way to save images is as follows. When you open the app, tap and hold on a blank area of the screen. You will see the Paste option. Tap on Paste to save the images in that folder.\n",attributes: attributes as [NSAttributedString.Key : Any])
        aString1.append(aString5)
        
        let imageAttachment2 = NSTextAttachment()
        imageAttachment2.image = UIImage(systemName:"square.stack.fill")
        let imageString2 = NSAttributedString(attachment: imageAttachment2)
        aString1.append(imageString2)
        
        let aString3 = NSMutableAttributedString(string: " button will show your images shuffled in a random order.\n",attributes: attributes as [NSAttributedString.Key : Any])
        aString1.append(aString3)
        
        let imageAttachment3 = NSTextAttachment()
        imageAttachment3.image = UIImage(systemName:"trash")
        let imageString3 = NSAttributedString(attachment: imageAttachment3)
        aString1.append(imageString3)
        
        let aString4 = NSMutableAttributedString(string: " button will delete the top left image.\n",attributes: attributes as [NSAttributedString.Key : Any])
        aString1.append(aString4)
        
        let imageAttachment6 = NSTextAttachment()
        imageAttachment6.image = UIImage(systemName:"lock.fill")
        let imageString6 = NSAttributedString(attachment: imageAttachment6)
        aString1.append(imageString6)
        
        let aString6 = NSMutableAttributedString(string: " button will take you to the Security Settings view. You can set a password to open this file and also encrypt the contents of the file.\n",attributes: attributes as [NSAttributedString.Key : Any])
        aString1.append(aString6)
        
        
        
        helpText.attributedText = aString1
    }
    
    @IBOutlet weak var helpText: UITextView!
    @IBOutlet weak var doneButton: UIButton!
    
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
