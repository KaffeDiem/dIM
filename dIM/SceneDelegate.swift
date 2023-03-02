//
//  SceneDelegate.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 23/08/2021.
//

import UIKit
import SwiftUI
import CoreData
import UserNotifications

/// Default class generated for iOS apps.
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var window: UIWindow?
    lazy var appSession = AppSession(context: context)

    /// Handle deep links for scanning contacts from the camera app.
    ///
    /// - Note: URL should be formatted as dim://username//publickey
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url{
            let urlStr = url.absoluteString
            appSession.addUserFromQrScan(urlStr)
        }
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        migrateIfNecessary()
        
        let contentView = SetupView()
            .environment(\.managedObjectContext, context)
            .environmentObject(appSession)
        
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    /// Save data to CoreData when app is closed
    func sceneDidEnterBackground(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
    
    /// Migrate users prior to version 2.*
    private func migrateIfNecessary() {
        // Username used to be stored as 'Username' in UserDefaults with its digits.
        guard let username = UserDefaults.standard.string(forKey: "Username") else {
            print("-- NO NEED TO MIGRATE USER --")
            return
        }
        
        let components = username.components(separatedBy: "#")
        
        guard components.count == 3 else {
            print("-- COULD NOT MIGRATE USER --")
            return
        }
        
        UserDefaults.standard.set(components[0], forKey: UserDefaultsKey.username.rawValue)
        UserDefaults.standard.set(components[2], forKey: UserDefaultsKey.userId.rawValue)
        UserDefaults.standard.removeObject(forKey: "Username")
    }
}

