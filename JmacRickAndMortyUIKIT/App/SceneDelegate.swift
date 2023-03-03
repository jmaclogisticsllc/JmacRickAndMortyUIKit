//
//  SceneDelegate.swift
//  JmacRickAndMortyUIKIT
//
//  Created by Tom on 11/2/22.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        if let windowScene = scene as? UIWindowScene {
            
            let mapVC = MainMapViewController()
            mapVC.tabBarItem = UITabBarItem(title: "MapView", image: UIImage(systemName: "map"), tag: 0)
            let characterVC = CharacterViewController()
            characterVC.tabBarItem = UITabBarItem(title: "CharacterView", image: UIImage(systemName: "star"), tag: 1)
            
            let videoVC = VideoViewController()
            videoVC.tabBarItem = UITabBarItem(title: "VideoChat", image: UIImage(systemName: "video"), tag: 2)
            
            let mapNavController = UINavigationController(rootViewController: mapVC)
            let characterNavController = UINavigationController(rootViewController: characterVC)
            let videoNavController = UINavigationController(rootViewController: videoVC)
            
            let tabBarController = UITabBarController()
            tabBarController.viewControllers = [mapNavController, characterNavController, videoNavController]
            tabBarController.selectedIndex = 0
            
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = tabBarController
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
    }


}

