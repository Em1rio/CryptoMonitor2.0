//
//  SceneDelegate.swift
//  CryptoMonitorMVVM
//
//  Created by Emir Nasyrov on 03.11.2023.
//

import Foundation
import UIKit
import RealmSwift

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var appCoordinator: Coordinator?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard (scene is UIWindowScene) else { return }
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            self.window = window
            
            NetworkMonitor.shared.startMonitoring()
            let config = Realm.Configuration(schemaVersion: 3, migrationBlock: {migration, oldSchema in if oldSchema < 3{}})
            Realm.Configuration.defaultConfiguration = config
            let _ = try! Realm()
            
            let navController = UINavigationController()
            navController.isNavigationBarHidden = true
            let networkManager = NetworkManager()
            let dataBaseManager = DBManager()
            
            appCoordinator = AppCoordinator(window: window,
                                            navigationController: navController,
                                            networkManager: networkManager,
                                            dataBaseManager: dataBaseManager)
            appCoordinator?.start()
            
            window.rootViewController = navController
            window.makeKeyAndVisible()
        }
    }
}
