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

    // MARK: Handle adding a new contact when scanning their QR code
    
    /*
     openURLContexts handles deep links for the app. They allow users to easily share
     contact information by scanning friends QR codes. This is the callback function
     which is activated when a user clicks on the dIM-link in the camera app.
     */
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url{
            let urlStr = url.absoluteString
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            
            /*
             Seperate the URL of the type dim//username//publickey
             into components which are then handled.
             */
            let component = urlStr.components(separatedBy: "//")
            
            guard component.count == 3 else {
                print("QR code error: Format of scanned QR code is wrong.")
                return
            }
            
            let name = component[1]
            let publicKey = component[2]
            
            let fetchRequest: NSFetchRequest<ConversationEntity>
            fetchRequest = ConversationEntity.fetchRequest()
            
            do {
                /*
                 Get existing conversations from Core Data.
                 */
                let conversations = try context.fetch(fetchRequest)
                
                /*
                 Check if a contact with that username already exists.
                 */
                for c in conversations {
                    if c.author == name {
                        print("ERROR: Contact has been added already.")
                        return
                    }
                }
            } catch {
                print("No previously added contacts. Adding first.")
            }
            
            /*
             Create the new conversation to be added and saved to Core Data.
             */
            let conversation = ConversationEntity(context: context)
            conversation.author = name
            conversation.publicKey = publicKey
            
            print("Added new contact to conversation: \(name)")
            
            do {
                try context.save()
            } catch {
                print("Error: Could not save context while adding new contact.")
            }
        }
    }
    

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        // Get the managed object context from the shared persistent container.
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        // Create the SwiftUI view that provides the window contents.
        let contentView = SetUpView()
            .environment(\.managedObjectContext, context)

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

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
}

