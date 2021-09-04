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

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    
    /*
     openURLContexts handles deep links for the app. They allow users to easily share
     contact information by scanning friends QR codes. This is the callback function
     which is activated when a user clicks on the dIM-link in the camera app.
     */
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url{
            let urlStr = url.absoluteString
            
            /*
             Seperate the URL of the type dim//username//publickey
             into components which are then handled.
             */
            let component = urlStr.components(separatedBy: "//")
            
            guard component.count == 3 else { return }
            
            let name = component[1]
            let publicKey = component[2]
            
            let defaults = UserDefaults.standard
            
            /*
             If a contact list exists already then add the new contact to it.
             */
            if var contacts = defaults.stringArray(forKey: "Contacts") {
                if contacts.contains(name) {
                    print("Contact has already been added. ")
                    return
                }
                
                contacts.append(name)
                defaults.set(contacts, forKey: "Contacts")
                
            } else { // Otherwise create a new contact list.
                let contacts = [name]
                
                defaults.set(contacts, forKey: "Contacts")
            }
            
            /*
             Save the new public key received from the user.
             */
            defaults.set(publicKey, forKey: name)
        }
        
        let contacts = UserDefaults.standard.stringArray(forKey: "Contacts")
        
        /*
         Print all contacts and their public keys.
         */
        for contact in contacts! {
            print("\(contact): \(UserDefaults.standard.string(forKey: contact)!)")
        }
    }
    

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        // Create the SwiftUI view that provides the window contents.
        
//        let context = persistentContainer.viewContext
//        let contentView = SetUpView().environment(\.managedObjectContext, context)
        
        let contentView = SetUpView()

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

//        saveContext()
//        print("Save context is called.")
    }

    lazy var persistentContainer: NSPersistentContainer = {
          let container = NSPersistentContainer(name: "Conversations")
          container.loadPersistentStores { _, error in
                if let error = error as NSError? {
                    // MARK: TODO - You should add your own error handling code here.
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
          }
      return container
    }()
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // MARK: TODO - You should add your own error handling code here.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

