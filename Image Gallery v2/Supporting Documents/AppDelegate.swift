//
//  AppDelegate.swift
//  Image Gallery v2
//
//  Created by Raj Gupta on 21/10/18.
//  Copyright © 2018 SoulfulMachine. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, EnterPasswordViewContollerDelegate {
    
    func passwordResult(showImages: Bool, showEnterPassword: Bool) {
        if showImages {
            if let lastVC = lastActiveViewController {
                activeWindow?.rootViewController?.present(lastVC, animated: true, completion: nil)
            }
        }
        else {
            documentPassword = nil
        }
    }
    
    
    var documentPassword: String?
    var isPasteLinkActive = false
    var lastActiveViewController: UIViewController?
    
    var isPasswordProtected: Bool {
        return documentPassword != nil
    }


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Set up global navigation bar appearance
        configureNavigationBarAppearance()
        PremiumAnimationsStore.shared.start()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        handleWillResignActive()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        handleDidEnterBackground()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        handleWillEnterForeground()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
    }
    
    private func showPasswordScreen() {
        print("Attempting to show password screen")
        guard let window = activeWindow else {
            print("Window is not available")
            return
        }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let passwordVC = storyboard.instantiateViewController(withIdentifier: "enterPassword") as? EnterPasswordViewController {
            print("EnterPasswordViewController instantiated")
            passwordVC.correctPassword = documentPassword
            passwordVC.delegate = self
            passwordVC.modalPresentationStyle = .fullScreen
            
            if let rootViewController = window.rootViewController {
                print("Presenting EnterPasswordViewController after delay")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if let presentedVC = rootViewController.presentedViewController {
                        print("Already presented view controller found, dismissing it first")
                        presentedVC.dismiss(animated: false) {
                            print("Presenting EnterPasswordViewController after dismissing the current one")
                            rootViewController.present(passwordVC, animated: true, completion: nil)
                        }
                    } else {
                        print("No presented view controller found, presenting EnterPasswordViewController")
                        rootViewController.present(passwordVC, animated: true, completion: nil)
                    }
                }
            } else {
                print("Root view controller is not available")
            }
        } else {
            print("Failed to instantiate EnterPasswordViewController")
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        configuration.delegateClass = SceneDelegate.self
        configuration.storyboard = nil
        return configuration
    }

    func application(_ app: UIApplication, open inputURL: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        // Ensure the URL is a file URL
        guard inputURL.isFileURL else { return false }
                
        // Reveal / import the document at the URL
        guard let documentBrowserViewController = activeWindow?.rootViewController as? DocumentBrowserViewController else { return false }

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
        if let windowScene = activeWindow?.windowScene {
            blankScreenWindow = UIWindow(windowScene: windowScene)
            blankScreenWindow?.frame = windowScene.coordinateSpace.bounds
        } else {
            blankScreenWindow = UIWindow(frame: UIScreen.main.bounds)
        }
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
    
    var activeWindow: UIWindow? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        return scenes.lazy.flatMap(\.windows).first(where: \.isKeyWindow) ?? scenes.lazy.flatMap(\.windows).first
    }
    
    func handleWillResignActive() {
        if !isPasteLinkActive {
            lastActiveViewController = activeWindow?.rootViewController?.presentedViewController
            if isPasswordProtected {
                activeWindow?.rootViewController?.presentedViewController?.dismiss(animated: false)
            }
        }
    }
    
    func handleDidEnterBackground() {
        showBlankScreenWindow()
    }
    
    func handleWillEnterForeground() {
        if isPasswordProtected {
            showPasswordScreen()
        }
        hideBlankScreen()
    }


}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = storyboard.instantiateInitialViewController()
        self.window = window
        window.makeKeyAndVisible()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.handleWillResignActive()
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.handleDidEnterBackground()
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.handleWillEnterForeground()
    }
}
