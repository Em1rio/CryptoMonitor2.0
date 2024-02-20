//
//  AppCoordinator.swift
//  CryptoMonitorMVVM
//
//  Created by Emir Nasyrov on 01.11.2023.
//

import UIKit

protocol Coordinator: AnyObject {
    var parentCoordinator: Coordinator? { get set }
    var childCoordinators: [Coordinator] { get set }
    func start()
    func childDidFinish(_ child: Coordinator?)
}

final class AppCoordinator: Coordinator {
    // MARK: - Variables
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var window: UIWindow?
    private var tabBarController: TabBarController?
    private var networkManager: NetworkManagerProtocol
    private var dataBaseManager: DBManagerProtocol
    // MARK: - Lifecycle
    init(window: UIWindow, navigationController: UINavigationController, networkManager: NetworkManagerProtocol, dataBaseManager: DBManagerProtocol) {
        self.window = window
        self.navigationController = navigationController
        self.networkManager = networkManager
        self.dataBaseManager = dataBaseManager
        window.makeKeyAndVisible()
    }
    // MARK: - Setup
    func start() {
        let tabBarCoordinator = TabBarCoordinator(
            navigationController, networkManager, dataBaseManager)
        tabBarCoordinator.parentCoordinator = self
        tabBarCoordinator.start()
        childCoordinators.append(tabBarCoordinator)
    }
    
}
// MARK: - Default values and methods for protocol
extension Coordinator {
    var parentCoordinator: Coordinator? { nil }
    
    func childDidFinish(_ child: Coordinator?) {
        for (index, coordinator) in
                childCoordinators.enumerated() {
            if coordinator === child {
                childCoordinators.remove(at: index)
                break
            }
        }
    }
}
