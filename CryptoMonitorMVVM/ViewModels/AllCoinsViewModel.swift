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
    private(set) var isLoading: Observable<Bool> = Observable(false)
    private(set) var isBadConnection: Observable<Bool> = Observable(false)
    private var dataFromAPI: [Datum]?
    private var dataFromDB: [AllCoinsDBModel]?
    private(set) var cellDataSource: Observable<[AllCoinsCellModel]> = Observable(nil)
    
    // MARK: - Lifecycle
    init(_ networkManager: NetworkManagerProtocol,
         _ dataBaseManager: DBManagerProtocol) {
        self.networkManager = networkManager
        self.dataBaseManager = dataBaseManager
    }
    
    
    func loadData() {
        howOldDB()
        checkDatabase()
    }
    
    //MARK: - Check if the database is out of date
    private func howOldDB() {
        guard NetworkMonitor.shared.isConnected == true else {return}
        let date = Date()
        if UserDefaults.standard.object(forKey: "lastUpdate") as? Date == nil {
            //save
            UserDefaults.standard.set(date, forKey: "lastUpdate")
        } else {
            // read
            let lastUpdate = UserDefaults.standard.object(forKey: "lastUpdate") as! Date
            let timeInterval = date.timeIntervalSince(lastUpdate) / 86400
            // update
            if timeInterval >= 14 {
                UserDefaults.standard.set(date, forKey: "lastUpdate")
                fetchData()
            }
        }
    }
    
    //MARK: - Check Database for existing data
    private func checkDatabase() {
        if let allCoins = dataBaseManager.fetchFromDatabase() {
            // Если данные есть в базе, загружаем их и обновляем таблицу
            self.dataFromDB = allCoins
            self.mapCellData(from: dataFromDB)
        } else {
            // Если данных нет в базе, выполняем запрос к сети
            if NetworkMonitor.shared.isConnected {
                fetchData()
            } else {
                isBadConnection.value = true
            }
        }
    }
    //MARK: - Fetch Data from API
    private func fetchData() {
        isLoading.value = true
        networkManager.fetchCoins { [weak self] AllCoins, error in
            guard let self else {return}
            self.isLoading.value = false
            if error != nil {
                print("Ошибка при декодировании данных: \(String(describing: error))")
            } else if let AllCoins {
                self.dataFromAPI = AllCoins
                self.mapCellData(from: self.dataFromAPI)
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
    //MARK: - Prepare Data for TableView
    func numberOfRow(_ section: Int) -> Int {
        if let dataDB = dataFromDB, !dataDB.isEmpty {
            return dataDB.count
        } else {
            return dataFromAPI?.count ?? 0
        }
    }
    
    private func mapCellData<T>(from data: [T]?) {
        var cellModels = [AllCoinsCellModel]()
        if T.self == Datum.self {
            if let data = data as? [Datum] {
                cellModels = data.map { AllCoinsCellModel($0) }
            }
        } else if T.self == AllCoinsDBModel.self {
            if let data = data as? [AllCoinsDBModel] {
                cellModels = data.map { AllCoinsCellModel($0) }
            }
        }
        cellDataSource.value = cellModels
    }
    
    
}
