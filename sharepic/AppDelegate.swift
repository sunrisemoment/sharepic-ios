//
//  AppDelegate.swift
//  sharepic
//
//  Created by steven on 9/8/2016.
//  Copyright © 2016 allyouneedapp. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import FirebaseMessaging
import FirebaseInstanceID
import FBSDKLoginKit
import FBSDKCoreKit
import FBSDKShareKit
import IQKeyboardManagerSwift
import UserNotifications
import AVFoundation

let kNOTIFICATION_NEW_STICKERS_DOWNLOAD_COMPLETED = "new_stickers_download_completed"
var bgMusic: AVAudioPlayer!

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate, AVAudioPlayerDelegate {

    var window: UIWindow?
    var isTriedDownload = false
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //set status bar style
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
        setStatusBarBackgroundColor(color: UIColor.black)
        
        IQKeyboardManager.sharedManager().enable = true
        
        // [START register_for_notifications]
        if #available(iOS 10.0, *) {
            let authOptions : UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_,_ in })
            
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            // For iOS 10 data message (sent via FCM)
            FIRMessaging.messaging().remoteMessageDelegate = self
            
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        // [END register_for_notifications]
        
        FIRApp.configure()
        
        // Add observer for InstanceID token refresh callback.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.tokenRefreshNotification),
                                               name: .firInstanceIDTokenRefresh,
                                               object: nil)

        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            if let user = user {
                SharePicUtil.currentUser = user
                //Start UPDATE00002
                let userID = FIRAuth.auth()?.currentUser?.uid
                var ref: FIRDatabaseReference!
                ref = FIRDatabase.database().reference()
                ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
                    let value = snapshot.value as? NSDictionary
                    FCMToken = value?["FCMToken"] as? String ?? ""
                    print(FCMToken)
                    
                }) { (error) in
                    print(error.localizedDescription)
                }
                
                if FCMToken == ""{
                    if let FCMToken = FIRInstanceID.instanceID().token(){
                        let userTable = FIRDatabase.database().reference().child("users")
                        userTable.child(user.uid).updateChildValues(["FCMToken": FCMToken])
                    }
                }
                // End UPDATE00002
                //check and download completed stickers if available
                if !self.isTriedDownload {
                    self.isTriedDownload = true
                    SharePicUtil.checkCompletedStickers(user.uid, completedSuggestedWords: { (error, suggestedWords) in
                        
                        var titles: String = ""
                        var downloadWord_count: Int = 0
                        for wordinfo in suggestedWords {
                            let suggestedWord_id = wordinfo["id"] as! String
                            let suggestedWord_title = wordinfo["title"] as! String
                            
                            let downloadedStickers = SharePicUtil.getDownloadedStickersWithSuggestedWordId(suggestedWord_id)
                            if downloadedStickers.isEmpty {
                                titles = titles + "\n\"\(suggestedWord_title)\", "
                                downloadWord_count += 1
                            }
                        }
                        
                        if downloadWord_count > 0 {
                            let block: DTAlertViewButtonClickedBlock = {(alertView, buttonIndex, cancelButtonIndex) in
                                
                                if buttonIndex == cancelButtonIndex {
                                    alertView?.dismiss()
                                }
                                else {//if click OK
                                    CommonFunc.showMBProgressHud(on: self.window, withText: "Downloading...", delay: 2.0)
                                    for wordinfo in suggestedWords {
                                        let suggestedWord_id = wordinfo["id"] as! String
                                        
                                        let downloadedStickers = SharePicUtil.getDownloadedStickersWithSuggestedWordId(suggestedWord_id)
                                        if downloadedStickers.isEmpty {//should download
                                            
                                            SharePicUtil.parseJsonFromServer(suggestedWord_id, completion: { (error, sticker_ids) in
                                                if let sticker_ids = sticker_ids {
                                                    var downloadStickersCount_perWord: Int = sticker_ids.count
                                                    for sticker_id in sticker_ids {
                                                        SharePicUtil.downloadSticker(sticker_id, suggestWord_id: suggestedWord_id, completion: { (error, sticker) in
                                                            downloadStickersCount_perWord -= 1
                                                            if downloadStickersCount_perWord == 0 {
                                                                downloadWord_count -= 1
                                                            }
                                                            if downloadWord_count == 0 {
                                                                DTAlertView(title: "Download Completed", message: "You can use the new stickers by adding sticker", delegate: nil, cancelButtonTitle: "Ok", positiveButtonTitle: nil).show()
                                                                NotificationCenter.default.post(name: Notification.Name(rawValue: kNOTIFICATION_NEW_STICKERS_DOWNLOAD_COMPLETED), object: nil)
                                                            }
                                                        })
                                                    }
                                                }
                                            })
                                        }
                                    }
                                }
                            }
                            DTAlertView(block: block, title: "Confirm!", message: "There are some stickers available to be downloaded for suggested word(s) as follow.\(titles)", cancelButtonTitle: "Cancel", positiveButtonTitle: "Download").show()
                        }
                        
                    })
                }
            } else {
                SharePicUtil.currentUser = nil
            }
        }

        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        iRate.sharedInstance().onlyPromptIfLatestVersion = false
        CJPAdController.sharedInstance().initialDelay = 2.0
        CJPAdController.sharedInstance().adMobUnitID = "ca-app-pub-9318863419427951/7656481029"
//        CJPAdController.sharedInstance().testDeviceIDs = ["f4e0bb1a143ba8c4e0c1828b405114c2e9d0800b"]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let navController = (storyboard.instantiateInitialViewController() as! UINavigationController)
        CJPAdController.sharedInstance().start(with: navController)
        self.window?.rootViewController! = CJPAdController.sharedInstance()

        let path = Bundle.main.path(forResource: "bgMusic.mp3", ofType:nil)!
        do {
            bgMusic = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            bgMusic.delegate = self
            bgMusic.numberOfLoops = -1
            bgMusic.play()
        } catch{
            print("Sound: Cannot load sound file")
        }
        return true
    }

    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // Print message ID.
        print("Message ID: \(userInfo["gcm.message_id"]!)")
        
        // Print full message.
        print("%@", userInfo)
    }
    // [END receive_message]
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        FIRMessaging.messaging().disconnect()
        print("Disconnected from FCM.")
        bgMusic.stop()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        bgMusic.play()
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        connectToFcm()
    }
    
    // [START refresh_token]
    func tokenRefreshNotification(_ notification: Notification) {
        if let refreshedToken = FIRInstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
            FCMToken = refreshedToken
            //if tokenRefresh -> put info to table Start UPDATE00002
            let userTable = FIRDatabase.database().reference().child("users")
            if let userID = FIRAuth.auth()?.currentUser?.uid{
                userTable.child(userID).updateChildValues(["FCMToken": FCMToken])
            }
            //End UPDATE00002
        }
        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
    }
    // [END refresh_token]
    
    // [START connect_to_fcm]
    func connectToFcm() {
        FIRMessaging.messaging().connect { (error) in
            if (error != nil) {
                print("Unable to connect with FCM. \(error)")
            } else {
                print("Connected to FCM.")
            }
        }
    }
    // [END connect_to_fcm]

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.allyouneedapp.sharepicios.sharepic" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "sharepic", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    //MARK: - Google Signin Handling
    //Google Login
    @available(iOS 9.0, *)
    func application(_ application: UIApplication,
                     open url: URL, options: [UIApplicationOpenURLOptionsKey: Any]) -> Bool {
        
        let handled = FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String!, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        
        if handled {
            return handled
        }
        
        return GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }
    
    //for IOS 8
    @available(iOS, introduced: 8.0, deprecated: 9.0)
    func application(_ application: UIApplication,
                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        //for facebook
        let handled = FBSDKApplicationDelegate.sharedInstance().application(
            application,
            open: url,
            sourceApplication: sourceApplication,
            annotation: annotation)
        
        if handled {
            return handled
        }
        
        
        //for google signin
        return GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication!, annotation: annotation)
    }
    //change status bar color
    func setStatusBarBackgroundColor(color: UIColor) {
        
        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
        statusBar.backgroundColor = color
    }
}

// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        // Print message ID.
        print("Message ID: \(userInfo["gcm.message_id"]!)")
        
        // Print full message.
        print("%@", userInfo)
    }
}

extension AppDelegate : FIRMessagingDelegate {
    // Receive data message on iOS 10 devices.
    func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
        print("%@", remoteMessage.appData)
    }
}
