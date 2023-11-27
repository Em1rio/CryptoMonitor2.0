//
//  AllCoinsCoordinator.swift
//  CryptoMonitorMVVM
//
//  Created by Emir Nasyrov on 02.11.2023.
//

import UIKit

final class AllCoinsCoordinator: Coordinator {
    weak var parentCoordinator: MainCoordinator?
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var dataFromSelected: ((AllCoinsCellModel) -> Void)?
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
        let networkManager = NetworkManager()
        let dataBaseManager = DBManager()
        let allCoinsViewModel = AllCoinsViewModel(networkManager, dataBaseManager)
        let allCoinsViewController = AllCoinsViewController(allCoinsViewModel, coordinator: self)
        allCoinsViewController.title = "All Coins"
        allCoinsViewController.dataFromSelected = { [weak self] AllCoinsCellModel in
            self?.dataFromSelected?(AllCoinsCellModel)
            
        }
        
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let sceneDelegate = scene.delegate as? SceneDelegate, let window = sceneDelegate.window {
                window.rootViewController?.present(allCoinsViewController, animated: true, completion: nil)
            }
        }
    }

    func didFinish() {
        parentCoordinator?.childDidFinish(self)
    }
}

