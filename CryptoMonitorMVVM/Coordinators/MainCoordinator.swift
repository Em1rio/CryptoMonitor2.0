//
//  MainCoordinator.swift
//  CryptoMonitorMVVM
//
//  Created by Emir Nasyrov on 01.11.2023.
//

import Foundation
import UIKit

final class MainCoordinator: Coordinator {
    
    var parentCoordinator: TabBarCoordinator?
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    private var networkManager: NetworkManagerProtocol
    private var dataBaseManager: DBManagerProtocol
        
    init(_ navigationController: UINavigationController,
         _ networkManager: NetworkManagerProtocol,
         _ dataBaseManager: DBManagerProtocol) {
            self.navigationController = navigationController
            self.networkManager = networkManager
            self.dataBaseManager = dataBaseManager
        }
    func start() {
        let mainViewModel = MainViewModel(networkManager, dataBaseManager)
        let mainViewController = MainViewController(mainViewModel, coordinator: self)
        navigationController = UINavigationController(rootViewController: mainViewController)
        parentCoordinator?.childCoordinators.append(self)
    }

}

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
