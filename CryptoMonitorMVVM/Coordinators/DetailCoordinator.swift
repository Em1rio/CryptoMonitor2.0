//
//  DetailCoordinator.swift
//  CryptoMonitorMVVM
//
//  Created by Emir Nasyrov on 04.12.2023.
//

import Foundation
import UIKit

final class DetailCoordinator: Coordinator {
    // MARK: - Variables
    weak var parentCoordinator: AllAssetsCoordinator?
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
        let datailViewModel = DetailViewModel(networkManager, dataBaseManager)
        let detailViewController = DetailViewController(datailViewModel, coordinator: self)
        detailViewController.title = "Detail" // Подставить тайтл в соответсвии с названием
        navigationController.pushViewController(detailViewController, animated: true)
        navigationController.setNavigationBarHidden(false, animated: false)
        
        
    }
   
    
    
}



