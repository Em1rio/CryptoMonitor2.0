//
//  AllAssetsViewModel.swift
//  CryptoMonitorMVVM
//
//  Created by Emir Nasyrov on 18.10.2023.
//

import Foundation

final class AllAssetsViewModel {
    // MARK: - Variables
    private let networkManager: NetworkManagerProtocol
    private let dataBaseManager: DBManagerProtocol

    // MARK: - Lifecycle
    init(_ networkManager: NetworkManagerProtocol,
         _ dataBaseManager: DBManagerProtocol) {
        self.networkManager = networkManager
        self.dataBaseManager = dataBaseManager
    }
    //MARK: - Data source for TableView
    let allAssetsModel = ["BTC", "ETC", "LTC", "ETC", "ETC", "ETC", "ETC", "ETC", "ETC", "ETC"]
    
//    func fetchTickerDetails(withID id: String) {
//        networkManager.fetchTickerDetails(withID: id) { result in
//            switch result {
//            case .success(let data):
//                // Обработка данных о деталях тикера
//            case .failure(let error):
//                // Обработка ошибки
//            }
//        }
//    }
}
