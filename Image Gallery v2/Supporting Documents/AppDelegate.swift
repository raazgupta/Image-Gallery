//
//  AppDelegate.swift
//  Image Gallery v2
//
//  Created by Raj Gupta on 21/10/18.
//  Copyright © 2018 SoulfulMachine. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Set up global navigation bar appearance
        configureNavigationBarAppearance()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        showBlankScreenWindow()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        hideBlankScreen()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ app: UIApplication, open inputURL: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        // Ensure the URL is a file URL
        guard inputURL.isFileURL else { return false }
                
        // Reveal / import the document at the URL
        guard let documentBrowserViewController = window?.rootViewController as? DocumentBrowserViewController else { return false }

        documentBrowserViewController.revealDocument(at: inputURL, importIfNeeded: true) { (revealedDocumentURL, error) in
            if let error = error {
                // Handle the error appropriately
                print("Failed to reveal the document at URL \(inputURL) with error: '\(error)'")
                return
            }
            
            // Present the Document View Controller for the revealed URL
            documentBrowserViewController.presentDocument(at: revealedDocumentURL!)
        }

        return true
    }
    
    private var blankScreenWindow: UIWindow?
    
    private func showBlankScreenWindow(){
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        blankScreenWindow = UIWindow(frame: UIScreen.main.bounds)
        blankScreenWindow?.rootViewController = storyBoard.instantiateViewController(withIdentifier: "blankScreen")
        blankScreenWindow?.windowLevel = .alert + 1
        blankScreenWindow?.makeKeyAndVisible()
    }
    
    private func hideBlankScreen() {
        blankScreenWindow?.isHidden = true
        blankScreenWindow = nil
    }
    
    private func configureNavigationBarAppearance() {
        // Set the title text color for all navigation bars
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.262745098, green: 0.7333333333, blue: 0.5294117647, alpha: 1)]
        
        // Optional: If you want to change the large title color as well
        UINavigationBar.appearance().largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.262745098, green: 0.7333333333, blue: 0.5294117647, alpha: 1)]
    }


}

