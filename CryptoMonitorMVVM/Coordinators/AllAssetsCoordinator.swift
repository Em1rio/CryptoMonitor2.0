//
//  AllAssetsCoordinator.swift
//  CryptoMonitorMVVM
//
//  Created by Emir Nasyrov on 01.11.2023.
//

import Foundation
import UIKit

final class AllAssetsCoordinator: Coordinator {
    
    // MARK: - Variables
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
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
        let allAssetsViewModel = AllAssetsViewModel(networkManager, dataBaseManager)
        let allAssetsViewController = AllAssetsViewController(allAssetsViewModel, coordinator: self)
        navigationController.setViewControllers([allAssetsViewController], animated: true)
        navigationController.setNavigationBarHidden(true, animated: false)
    }
}

extension AllAssetsCoordinator {
    func coordinateToDetail(with tiker: String) {
        let detailCoordinator = DetailCoordinator(
            navigationController, networkManager, dataBaseManager)
        detailCoordinator.parentCoordinator = self
        detailCoordinator.title = tiker
        detailCoordinator.start()
        childCoordinators.append(detailCoordinator)
    }
}
