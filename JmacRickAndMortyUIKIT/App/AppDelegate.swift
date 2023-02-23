//
//  AppDelegate.swift
//  JmacRickAndMortyUIKIT
//
//  Created by Tom on 11/2/22.
//

import UIKit
import Datadog

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        Datadog.initialize(
            appContext: .init(),
            trackingConsent: .granted,
            configuration: Datadog.Configuration
                .builderUsing(clientToken: "pubb5b586479b274be0e1b107db1dde240c", environment: "dev")
                .set(serviceName: "ios-app")
                .set(endpoint: .us5)
                .trackBackgroundEvents()
                .build()
        )

        // Override point for customization after application launch.
        window = UIWindow()
        let characterVC = CharacterViewController()
        let videoVC = VideoViewController()
        
        let characterNavVC = UINavigationController(rootViewController: characterVC)
        let videoNavVC = UINavigationController(rootViewController: videoVC)
        
        let mainTabBar = UITabBarController()
        mainTabBar.viewControllers = [characterNavVC, videoNavVC]
        window?.rootViewController = mainTabBar
        window?.makeKeyAndVisible()
        
        
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {

        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {

    }


}

