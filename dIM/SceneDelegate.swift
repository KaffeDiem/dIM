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
        
#if targetEnvironment(macCatalyst)
        setupMacCatalystToolbar(for: scene)
#endif
        
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
    
#if targetEnvironment(macCatalyst)
    /// Create the Mac Catalyst toolbar. This will replace the NavigationView toolbar
    /// otherwise created in SwiftUI.
    /// - Parameter scene: UIScene for the toolbar.
    private func setupMacCatalystToolbar(for scene: UIScene) {
        guard let windowScene = (scene as? UIWindowScene) else { fatalError("Could not create the Mac Catalyst toolbar") }
        if let titlebar = windowScene.titlebar {
            //toolbar
            let identifier = NSToolbar.Identifier(toolbarIdentifier)
            let toolbar = NSToolbar(identifier: identifier)
            toolbar.allowsUserCustomization = true
            toolbar.centeredItemIdentifier = NSToolbarItem.Identifier(rawValue: centerToolbarIdentifier)
            titlebar.toolbar = toolbar
            titlebar.toolbarStyle = .expanded
            titlebar.toolbar?.delegate = self
            titlebar.titleVisibility = .hidden
            titlebar.autoHidesToolbarInFullScreen = true
        }
    }
#endif
    
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

#if targetEnvironment(macCatalyst)
let toolbarIdentifier = "com.example.apple-samplecode.toolbar"
let centerToolbarIdentifier = "com.example.apple-samplecode.centerToolbar"
let addToolbarIdentifier = "com.example.apple-samplecode.add"

extension SceneDelegate: NSToolbarDelegate {
    
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        if itemIdentifier == NSToolbarItem.Identifier(rawValue: toolbarIdentifier) {
            let group = NSToolbarItemGroup(itemIdentifier: NSToolbarItem.Identifier(rawValue: toolbarIdentifier), titles: ["Solver", "Resistance", "Settings"], selectionMode: .selectOne, labels: ["section1", "section2", "section3"], target: self, action: #selector(toolbarGroupSelectionChanged))
            
            group.setSelected(true, at: 0)
            
            return group
        }
        
        if itemIdentifier == NSToolbarItem.Identifier(rawValue: centerToolbarIdentifier) {
            let group = NSToolbarItemGroup(itemIdentifier: NSToolbarItem.Identifier(rawValue: centerToolbarIdentifier), titles: ["Solver1", "Resistance1", "Settings1"], selectionMode: .selectOne, labels: ["section1", "section2", "section3"], target: self, action: #selector(toolbarGroupSelectionChanged))
            
            group.setSelected(true, at: 0)
            
            return group
        }
        
        if itemIdentifier == NSToolbarItem.Identifier(rawValue: addToolbarIdentifier) {
            let barButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(self.add(sender:)))
            let button = NSToolbarItem(itemIdentifier: itemIdentifier, barButtonItem: barButtonItem)
            return button
        }
        
        return nil
    }
    
    @objc func toolbarGroupSelectionChanged(sender: NSToolbarItemGroup) {
        print("selection changed to index: \(sender.selectedIndex)")
    }
    
    @objc func add(sender: UIBarButtonItem) {
        print("add clicked")
    }
    
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [NSToolbarItem.Identifier(rawValue: toolbarIdentifier), NSToolbarItem.Identifier(rawValue: centerToolbarIdentifier), NSToolbarItem.Identifier.flexibleSpace,
         NSToolbarItem.Identifier(rawValue: addToolbarIdentifier),
         NSToolbarItem.Identifier(rawValue: addToolbarIdentifier)]
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        self.toolbarDefaultItemIdentifiers(toolbar)
    }
    
}
#endif
