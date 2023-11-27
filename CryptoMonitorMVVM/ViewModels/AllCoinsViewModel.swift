//
//  AllCoinsViewModel.swift
//  CryptoMonitorMVVM
//
//  Created by Emir Nasyrov on 18.10.2023.
//

import Foundation

final class AllCoinsViewModel {
    // MARK: - Variables
    private let networkManager: NetworkManagerProtocol
    private let dataBaseManager: DBManagerProtocol
    var isLoading: Observable<Bool> = Observable(false)
    var cellDataSource: Observable<[AllCoinsCellModel]> = Observable(nil)
    var dataSource: [Datum]?
    
    // MARK: - Lifecycle
    init(_ networkManager: NetworkManagerProtocol,
         _ dataBaseManager: DBManagerProtocol) {
        self.networkManager = networkManager
        self.dataBaseManager = dataBaseManager
    }

    //MARK: - Prepare Data for TableView
    func numberOfRow(_ section: Int) -> Int {
        dataSource?.count ?? 0
    }
    
    func mapCellData() {
        cellDataSource.value = dataSource?.compactMap({AllCoinsCellModel($0)})
    }
    
    //MARK: - Fetch Data from API
    func fetchData() {
        isLoading.value = true
        networkManager.fetchCoins { [weak self] AllCoins, error in
            guard let self else {return}
            self.isLoading.value = false
            if error != nil {
                print("Ошибка при декодировании данных: \(String(describing: error))")
            } else if let AllCoins {
                self.dataSource = AllCoins
                self.mapCellData()
                
                DispatchQueue.main.async {
                self.loadDataToDB(AllCoins)
                }
            }
        }
        
    }
    private func loadDataToDB(_ allCoins: [Datum]) {

        for coin in allCoins {
            let newData = AllCoinsDBModel()
            newData.id = coin.id
            newData.symbol = coin.symbol
            newData.name = coin.name
            dataBaseManager.saveDataFromApi(newData)
        }
        
    }
    
}
