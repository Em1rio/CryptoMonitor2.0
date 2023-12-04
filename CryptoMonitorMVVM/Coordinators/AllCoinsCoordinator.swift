//
//  AllCoinsCoordinator.swift
//  CryptoMonitorMVVM
//
//  Created by Emir Nasyrov on 02.11.2023.
//

import UIKit

final class AllCoinsCoordinator: Coordinator {
    // MARK: - Variables
    weak var parentCoordinator: MainCoordinator?
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var dataFromSelected: ((AllCoinsCellModel) -> Void)?
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
        let allCoinsViewModel = AllCoinsViewModel(networkManager, dataBaseManager)
        let allCoinsViewController = AllCoinsViewController(allCoinsViewModel, coordinator: self)
        allCoinsViewController.title = "All Coins"
        allCoinsViewController.dataFromSelected = { [weak self] AllCoinsCellModel in
            self?.dataFromSelected?(AllCoinsCellModel)
            
        }
        navigationController.present(allCoinsViewController, animated: true)

    }
    // MARK: - Actions
    func didFinish() {
        parentCoordinator?.childDidFinish(self)
    }
}

