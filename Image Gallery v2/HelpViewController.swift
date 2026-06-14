//
//  SettingsViewController.swift
//  Image Gallery v2
//
//  Created by Raj Gupta on 2020/08/25.
//  Copyright © 2020 SoulfulMachine. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {
    private let bodyColor = UIColor.black
    private let headingColor = UIColor(red: 0.262745098, green: 0.7333333333, blue: 0.5294117647, alpha: 1)
    
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

        helpText.attributedText = makeHelpText()
    }
    
    @IBOutlet weak var helpText: UITextView!
    @IBOutlet weak var doneButton: UIButton!
    
    @IBAction func done(_ sender: UIButton) {
        dismiss(animated: true)
    }

    private func makeHelpText() -> NSAttributedString {
        let text = NSMutableAttributedString()

        appendHeading("Getting Started", to: text)
        appendBody("Image Store lets you save image links from the web or store image files directly. Saving links instead of full files helps reduce disk usage.\n\n", to: text)

        appendHeading("Saving Images", to: text)
        appendBullet(icon: "arrow.down.doc.fill", text: "Open a gallery, copy an image link in your browser, then tap the download button to add it.", to: text)
        appendBody("\n", to: text)

        appendHeading("Gallery Controls", to: text)
        appendBullet(icon: "gear", text: "Settings: configure password protection, encryption, star probabilities, and gacha animation style.", to: text)
        appendBullet(icon: "dice.fill", text: "Random Roll: tap the button, or pull down from the top of the gallery, to reveal a saved image with an animation.", to: text)
        appendBullet(icon: "magnifyingglass", text: "Search: filter the gallery to find matching images.", to: text)
        appendBullet(icon: "info.circle.fill", text: "Image Details: open the image details screen to set the title, star level, and favorite status for an image.", to: text)
        appendBullet(icon: "arrow.down.document.fill", text: "Download: add the latest copied image link or bulk-paste copied gallery items.", to: text)
        appendBullet(icon: "square.stack.fill", text: "Random Image: show your gallery images in a shuffled random order.", to: text)
        appendBullet(icon: "trash", text: "Delete Image: remove the top image after confirming the deletion.", to: text)
        appendBullet(icon: "questionmark.circle", text: "Help: reopen this guide at any time.", to: text)
        appendBody("\n", to: text)

        appendHeading("Touch And Hold", to: text)
        appendBullet(icon: "square.and.arrow.up.fill", text: "Copy: copy the selected image link.", to: text)
        appendBullet(icon: "heart.fill", text: "Favorite: mark an image as a favorite so it stands out in the gallery.", to: text)
        appendBullet(icon: "heart.slash.fill", text: "Unfavorite: remove the favorite mark from an image that is already favorited.", to: text)
        appendBullet(icon: "arrow.down.document.fill", text: "Paste: in the main gallery, insert the current copied image or copied multi-image payload below the pressed image.", to: text)
        appendBullet(icon: "checklist", text: "Select Multiple: choose several images at once so you can copy, delete, favorite, or unfavorite them together.", to: text)
        appendBullet(icon: "trash.fill", text: "Delete: remove the selected image after confirming the action.", to: text)
        appendBody("\n", to: text)

        appendHeading("Random Roll Animations", to: text)
        appendBody("Mystery Card is included for free. Additional random roll animations can be unlocked with a one-time $3 purchase from Settings.\n", to: text)
        appendBody("\nIn case you encounter any bugs or issues please contact: soulfulmachine84@gmail.com\n", to: text)

        return text
    }

    private func appendHeading(_ text: String, to attributedString: NSMutableAttributedString) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 8
        paragraphStyle.lineSpacing = 2

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 22, weight: .bold),
            .foregroundColor: headingColor,
            .paragraphStyle: paragraphStyle
        ]

        attributedString.append(NSAttributedString(string: text + "\n", attributes: attributes))
    }

    private func appendBody(_ text: String, to attributedString: NSMutableAttributedString) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 8
        paragraphStyle.lineSpacing = 4

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "American Typewriter", size: 18) ?? UIFont.systemFont(ofSize: 18),
            .foregroundColor: bodyColor,
            .paragraphStyle: paragraphStyle
        ]

        attributedString.append(NSAttributedString(string: text, attributes: attributes))
    }

    private func appendBullet(icon: String? = nil, text: String, to attributedString: NSMutableAttributedString) {
        if let icon {
            attributedString.append(makeIconAttachment(systemName: icon))
            appendBody("  " + text + "\n", to: attributedString)
        } else {
            appendBody("• " + text + "\n", to: attributedString)
        }
    }

    private func makeIconAttachment(systemName: String) -> NSAttributedString {
        let attachment = NSTextAttachment()
        let configuration = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        attachment.image = UIImage(systemName: systemName, withConfiguration: configuration)?.withTintColor(headingColor, renderingMode: .alwaysOriginal)
        attachment.bounds = CGRect(x: 0, y: -3, width: 18, height: 18)
        return NSAttributedString(attachment: attachment)
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
