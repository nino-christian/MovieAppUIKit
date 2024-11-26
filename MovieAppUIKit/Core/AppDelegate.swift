//
//  AppDelegate.swift
//  MovieAppUIKit
//
//  Created by Niño Christian Amahan on 11/18/24.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let isUserAuthenticated = true
        
        let homeScreenService: HomeScreenServiceProtocol = HomeScreenService()
        let favoriteMoviesManager: FavoriteMoviesManager = FavoriteMoviesManager()
        let homeScreenViewModel: HomeScreenViewModel = HomeScreenViewModel(homeScreenService: homeScreenService, favoriteMoviesManager: favoriteMoviesManager)
        
        let rootViewController: UIViewController = if isUserAuthenticated { HomeScreenViewController(homeScreenViewModel: homeScreenViewModel) } else { MainScreenViewController() }
        
        let navigationController: UINavigationController = UINavigationController(rootViewController: rootViewController)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

