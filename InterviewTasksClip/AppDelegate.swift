//
//  AppDelegate.swift
//  InterviewTasksClip
//
//  Created by Thejas K on 16/07/24.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let rootViewController = ViewController() // Replace with your initial view controller
        window?.rootViewController = rootViewController
        
        // Make the window visible
        window?.makeKeyAndVisible()
        
//        if let urlContext = launchOptions?[.urlContexts] as? Set<UIOpenURLContext> {
//            for context in urlContext {
//                print("AppDelegate_incomingURL : \(context.url)")
//            }
//        }
        
        if let userActivityDictionary = launchOptions?[.userActivityDictionary] as? [String: Any],
           let userActivity = userActivityDictionary["UIApplicationLaunchOptionsUserActivityKey"] as? NSUserActivity,
           userActivity.activityType == NSUserActivityTypeBrowsingWeb,
           let incomingURL = userActivity.webpageURL {
            print("AppDelegate_incomingURL_app_clip : \(incomingURL)")
        }
        else {
            print("dictionary_from_app_clip : \(launchOptions?[.userActivityDictionary])")
        }
        
        return true
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([any UIUserActivityRestoring]?) -> Void) -> Bool {
        
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
           let incomingURL = userActivity.webpageURL {
            print("AppDelegate_incomingURL_continue_user_activity: \(incomingURL)")
            
        }
        
        return true
    }

}

extension URL {
    var queryParameters: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else { return nil }
        var params = [String: String]()
        for item in queryItems {
            params[item.name] = item.value
        }
        return params
    }
}
