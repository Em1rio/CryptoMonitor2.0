//
//  MainCoordinator.swift
//  CryptoMonitorMVVM
//
//  Created by Emir Nasyrov on 01.11.2023.
//

import Foundation
import UIKit

final class MainCoordinator: Coordinator {
    // MARK: - Variables
    var parentCoordinator: TabBarCoordinator?
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
        let mainViewModel = MainViewModel(networkManager, dataBaseManager)
        let mainViewController = MainViewController(mainViewModel, coordinator: self)
        navigationController.setViewControllers([mainViewController], animated: true)
        navigationController.setNavigationBarHidden(true, animated: false)
        parentCoordinator?.childCoordinators.append(self)
    }

}
// MARK: - Actions
extension MainCoordinator {
    func coordinateToAllCoins(completion: @escaping (AllCoinsCellModel) -> Void) {
        let allCoinsCoordinator = AllCoinsCoordinator(
            navigationController, networkManager, dataBaseManager)
        allCoinsCoordinator.parentCoordinator = self
        childCoordinators.append(allCoinsCoordinator)
        allCoinsCoordinator.dataFromSelected = completion
        allCoinsCoordinator.start()
    }
    
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
