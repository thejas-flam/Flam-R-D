//
//  AppDelegate.swift
//  InterviewTasks
//
//  Created by Admin on 28/03/24.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    static let ClearInvocationUrlNotification = Notification.Name("Clear_Invocation_Url")
    static let RefreshViewAfterResetNotification = Notification.Name("Refresh_View_After_Url_Reset")

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        #if APP
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AppViewController") as? AppViewController {
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.rootViewController = viewController
            window?.makeKeyAndVisible()
        }
        #elseif APPCLIP
        
        let viewController = ViewController()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
        #endif
        
        if let userActivityDictionary = launchOptions?[.userActivityDictionary] as? [String: Any],
           let userActivity = userActivityDictionary["UIApplicationLaunchOptionsUserActivityKey"] as? NSUserActivity,
           userActivity.activityType == NSUserActivityTypeBrowsingWeb,
           let incomingURL = userActivity.webpageURL {
            
            var urlToUse = incomingURL.absoluteString
            
            if let value : String = userActivityDictionary["body"] as? String {
                urlToUse = value
            }
            
            print("AppDelegate_incomingURL_app_instance : \(urlToUse)")
            AppUserDefaults.invocationUrl.setValue_(value: urlToUse)
        }
        else {
            print("dictionary : \(launchOptions?[.userActivityDictionary])")
        }
                
        
        registerForPushNotifications()
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device_Token: \(token)")
        
        //self.sendDeviceTokenToServer(data: deviceToken)
        
    }
    
    
    
    func application(
      _ application: UIApplication,
      didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
      print("Failed to register: \(error)")
    }
    
    func registerForPushNotifications() {
        
        UNUserNotificationCenter.current()
            .requestAuthorization(
                options: [.alert, .sound, .badge]) { [weak self] granted, _ in
                    print("Permission granted: \(granted)")
                    guard granted else { return }
                    self?.getNotificationSettings()
                }
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([any UIUserActivityRestoring]?) -> Void) -> Bool {
        
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
           let incomingURL = userActivity.webpageURL {
            
            print("AppDelegate_incomingURL_form_app: \(incomingURL.absoluteString)")
            AppUserDefaults.invocationUrl.setValue_(value: incomingURL.absoluteString)
            //handleIncomingURL(incomingURL)
        }
        else {
            print("Failed to get invocation url")
        }
        
        return true
    }
    
    func getNotificationSettings() {
      UNUserNotificationCenter.current().getNotificationSettings { settings in
          print("Notification settings: \(settings)")
          guard settings.authorizationStatus == .authorized else { return }
          DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
          }
      }
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        guard let aps = userInfo["aps"] as? [String: AnyObject] else {
            return
        }
        
        // Extract the alert message if present
        if let alert = aps["alert"] as? [String: AnyObject] {
            let title = alert["title"] as? String
            if let body = alert["body"] as? String {
                print("AppDelegate_incomingURL_form_notification: \(body)")
                AppUserDefaults.invocationUrl.setValue_(value: body)
            }
            
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        NotificationCenter.default.post(name: AppDelegate.ClearInvocationUrlNotification, object: nil)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: AppDelegate.RefreshViewAfterResetNotification, object: nil)
        }
    }

}

