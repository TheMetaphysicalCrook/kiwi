//
//  AppDelegate.swift
//  Kiwi
//
//  Created by Mark Hudnall on 2/24/15.
//  Copyright (c) 2015 Mark Hudnall. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import FileKit
import SwiftyDropbox

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var filesystem: Filesystem = Filesystem.sharedInstance
    var syncEngine: SyncEngine = SyncEngine.sharedInstance
    var indexer: Indexer = Indexer.sharedInstance

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        Fabric.with([Crashlytics.self])
        
        DropboxClientsManager.setupWithAppKey(DropboxAppKey)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let rootNavigationController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController") as? BaseNavigationController
        
        if let client = DropboxClientsManager.authorizedClient {
            syncEngine.remote.configure(client: client)
        }
        
        let rootViewController = storyboard.instantiateViewController(withIdentifier: "LinkWithDropboxIdentifier") as? LinkWithDropboxViewController
        rootNavigationController?.viewControllers = [rootViewController!]
        
        
        self.window?.rootViewController = rootNavigationController
        self.window?.makeKeyAndVisible()
        let kiwiColor = Constants.KiwiColor
        UIToolbar.appearance().tintColor = kiwiColor
        UINavigationBar.appearance().tintColor = kiwiColor
        UISearchBar.appearance().tintColor = kiwiColor
        UITextField.appearance().tintColor = kiwiColor
        UITextView.appearance().tintColor = kiwiColor
        UINavigationBar.appearance().titleTextAttributes = [
            NSForegroundColorAttributeName: UINavigationBar.appearance().tintColor,
            NSFontAttributeName: UIFont.systemFont(ofSize: 0),
        ]
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        if let authResult = DropboxClientsManager.handleRedirectURL(url) {
            switch authResult {
            case .success:
                print("Success! User is logged into Dropbox.")
            case .cancel:
                print("Authorization flow was manually canceled by user!")
            case .error(_, let description):
                print("Error: \(description)")
            }
            
            EventBus.sharedInstance.publish(event: .AccountLinked(authResult: authResult))
        }
        
        return true
    }

    func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
        return true
    }
}

