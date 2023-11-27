//
//  AllAssetsCoordinator.swift
//  CryptoMonitorMVVM
//
//  Created by Emir Nasyrov on 01.11.2023.
//

import Foundation
import UIKit

final class AllAssetsCoordinator: Coordinator {
    var parentCoordinator: TabBarCoordinator?
    var childCoordinators: [Coordinator] = []
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
        let allAssetsViewModel = AllAssetsViewModel(networkManager, dataBaseManager)
        let allAssetsViewController = AllAssetsViewController(allAssetsViewModel, coordinator: self)
        navigationController = UINavigationController(rootViewController: allAssetsViewController)
        parentCoordinator?.childCoordinators.append(self)
    }

}
