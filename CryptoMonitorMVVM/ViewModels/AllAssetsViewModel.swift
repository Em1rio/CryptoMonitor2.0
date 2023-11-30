//
//  AllAssetsViewModel.swift
//  CryptoMonitorMVVM
//
//  Created by Emir Nasyrov on 18.10.2023.
//

import Foundation
import RealmSwift

final class AllAssetsViewModel {
    // MARK: - Variables
    private let networkManager: NetworkManagerProtocol
    private let dataBaseManager: DBManagerProtocol
    private(set) var coinsAsCategory: Results<CoinCategory>?
    var callTableView: (()-> Void)?

    // MARK: - Lifecycle
    init(_ networkManager: NetworkManagerProtocol,
         _ dataBaseManager: DBManagerProtocol) {
        self.networkManager = networkManager
        self.dataBaseManager = dataBaseManager
    }
    //MARK: - Data source for TableView
    func numberOfRow(_ section: Int) -> Int {
        if let coins = coinsAsCategory, !coins.isEmpty  {
            return coins.count
        } else {
            return 0
        }
        
    }
    func loadDataFromDatabase()  {
        coinsAsCategory = dataBaseManager.getCoinsAsCategory()
        callTableView?()
    }
    let allAssetsModel = ["ETH", "BTC"]
    
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
