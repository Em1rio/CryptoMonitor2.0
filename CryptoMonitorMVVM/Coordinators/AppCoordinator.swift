//
//  AppCoordinator.swift
//  CryptoMonitorMVVM
//
//  Created by Emir Nasyrov on 01.11.2023.
//

import UIKit

protocol Coordinator: AnyObject {
    //var parentCoordinator: Coordinator? { get set }
    var childCoordinators: [Coordinator] { get set }
    func start()
    func removeChildCoordinator(_ coordinator: Coordinator)
    func removeAllChildCoordinators()
}

final class AppCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var window: UIWindow?
    private var tabBarController: TabBarController?
    private var networkManager: NetworkManagerProtocol
    private var dataBaseManager: DBManagerProtocol
    
    init(window: UIWindow, navigationController: UINavigationController, networkManager: NetworkManagerProtocol, dataBaseManager: DBManagerProtocol) {
        self.window = window
        self.navigationController = navigationController
        self.networkManager = networkManager
        self.dataBaseManager = dataBaseManager
        window.makeKeyAndVisible()
    }
    func start() {
        let tabBarCoordinator = TabBarCoordinator(
            navigationController, networkManager, dataBaseManager)
        tabBarCoordinator.start()
        childCoordinators.append(tabBarCoordinator)
        }

}
extension Coordinator {
    func removeChildCoordinator(_ coordinator: Coordinator) {
        childCoordinators = childCoordinators.filter { $0 !== coordinator}
    }
    func removeAllChildCoordinators() {
        childCoordinators.removeAll()
    }
}
