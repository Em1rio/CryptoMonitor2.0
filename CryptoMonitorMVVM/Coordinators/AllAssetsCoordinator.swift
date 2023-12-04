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
    var parentCoordinator: TabBarCoordinator?
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
        parentCoordinator?.childCoordinators.append(self)
    }

}

extension AllAssetsCoordinator {
    func coordinateToDetail() {

        let detailCoordinator = DetailCoordinator(
            navigationController, networkManager, dataBaseManager)
        detailCoordinator.parentCoordinator = self
        childCoordinators.append(detailCoordinator)
        detailCoordinator.start()
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
