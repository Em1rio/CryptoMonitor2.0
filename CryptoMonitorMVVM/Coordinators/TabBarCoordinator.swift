//
//  TabBarCoordinator.swift
//  CryptoMonitorMVVM
//
//  Created by Emir Nasyrov on 02.11.2023.
//

import Foundation
import UIKit

final class TabBarCoordinator: Coordinator {
    // MARK: - Variables
    var parentCoordinator: AppCoordinator?
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    private var networkManager: NetworkManagerProtocol
    private var dataBaseManager: DBManagerProtocol
    // MARK: - Lifecycle
    init(_ navigationController: UINavigationController,
         _ networkManager: NetworkManagerProtocol,
         _ dataBaseManager: DBManagerProtocol) {
            self.navigationController = navigationController
            self.networkManager = networkManager
            self.dataBaseManager = dataBaseManager
        }
    // MARK: - Setup
    func start() {
        let mainCoordinator = MainCoordinator(
            navigationController, networkManager, dataBaseManager)
        let allAssetsCoordinator = AllAssetsCoordinator(
            navigationController, networkManager, dataBaseManager)
        childCoordinators.append(mainCoordinator)
        childCoordinators.append(allAssetsCoordinator)
        let tabBarController = TabBarController(childCoordinators: childCoordinators, networkManager: networkManager, dataBaseManager: dataBaseManager)
        
        // Создаем и добавляем вкладки в TabBarController
        let mainTab = UITabBarItem(title: "Запись", image: UIImage(systemName: "entry.lever.keypad"), tag: 0)
        let mainViewModel = MainViewModel(networkManager, dataBaseManager)
        let mainVC = MainViewController(mainViewModel, coordinator: mainCoordinator)
        mainVC.tabBarItem = mainTab
        mainCoordinator.start()

        let allAssetsTab = UITabBarItem(title: "Кошелёк", image: UIImage(systemName: "bitcoinsign"), tag: 1)
        let allAssetsViewModel = AllAssetsViewModel(networkManager, dataBaseManager)
        let allAssetsVC = AllAssetsViewController(allAssetsViewModel, coordinator: allAssetsCoordinator)
        allAssetsVC.tabBarItem = allAssetsTab
        allAssetsCoordinator.start()

        
        navigationController.setViewControllers([tabBarController], animated: true)
        tabBarController.viewControllers = [mainVC, allAssetsVC]
        
            
    }
    
    
}
