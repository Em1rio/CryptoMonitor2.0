//
//  TabBarController.swift
//  CryptoMonitorMVVM
//
//  Created by Emir Nasyrov on 26.10.2023.
//

import UIKit

final class TabBarController: UITabBarController {
    // MARK: - Variables
    private let childCoordinators: [Coordinator]
    private let networkManager: NetworkManagerProtocol
    private let dataBaseManager: DBManagerProtocol
        
    // MARK: - Initialization
    init(childCoordinators: [Coordinator], networkManager: NetworkManagerProtocol, dataBaseManager: DBManagerProtocol) {
            self.childCoordinators = childCoordinators
            self.networkManager = networkManager
            self.dataBaseManager = dataBaseManager
            super.init(nibName: nil, bundle: nil)
            configuration()
        }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configuration()
    }
    
    // MARK: - Setup
    private func configuration() {
        // Экземпляры ViewModel для каждой вкладки
        let mainViewModel = MainViewModel(networkManager, dataBaseManager)
        let allAssetsViewModel = AllAssetsViewModel(networkManager, dataBaseManager)
        // Создание ViewController для каждой вкладки и связка их с ViewModel
        let mainViewController = MainViewController(mainViewModel, coordinator:(childCoordinators.first(where: { $0 is MainCoordinator }) as? MainCoordinator)!)
        let allAssetsViewController = AllAssetsViewController(allAssetsViewModel, coordinator: (childCoordinators.first(where: { $0 is AllAssetsCoordinator }) as? AllAssetsCoordinator)!)
        // Установка вкладок в UITabBarController
        self.viewControllers = [mainViewController, allAssetsViewController]
    }


}
