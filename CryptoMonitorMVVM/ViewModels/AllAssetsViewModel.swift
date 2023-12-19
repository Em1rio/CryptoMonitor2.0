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
    private var totalCost: Decimal128 = 0.0
    private(set) var coinsAsCategory: Results<CoinCategory>?
    var callTableView: (()-> Void)?
    var callBalanceLabel: ((_ totalCost: String) -> Void)?

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
        } else { return 0}
    }
    func loadDataFromDatabase()  {
        coinsAsCategory = dataBaseManager.getObject(ofType: CoinCategory.self)
        callTableView?()
    }

    //MARK: - Update All Assets Cost Label
    func fetchDataFromDB() {
        totalCost = 0.0
        guard let coins = coinsAsCategory?.toArray(ofType: CoinCategory.self) as? [CoinCategory] else {return}
        for item in coins {
            fetchData(for: item)
        }
    }
    
   private func fetchData(for item: CoinCategory) {
        let idNumber = item._id
        networkManager.fetchTickerDetails(withID: idNumber) { result in
        switch result {
                case .success(let coinData):
                    do {
                        let coin = try JSONDecoder().decode([OneCoin].self, from: coinData)
                        self.coinsData(coin, for: item)
                    } catch {
                        print("Failed to decode coin data with error: \(error)")
                    }
                case .failure(let error):
                    print("Network request failed with error: \(error)")
                }
            }
    }
    
   private func coinsData(_ coin: [OneCoin] , for item: CoinCategory) {
       let priceRightNow = try! Decimal128(string: coin.first?.priceUsd ?? "0")
       DispatchQueue.main.async { [weak self] in
        guard let self = self, let coinID = coin.first?.id else { return }
           let realmQuery = self.dataBaseManager.getRealmQuery(
               forType: CoinCategory.self,
               where: "_id",
               equals: coinID)
           
                if let quantity = realmQuery.first?.coinQuantity {
                   let rawTotalCost = self.calculateTotalCost(priceRightNow, quantity)
                   self.totalCost += rawTotalCost
                   let formattedTotalCost = Formatter.shared.formatCurrency("\(self.totalCost)", useCustomFormatting: false)
                   self.updateUI(with: formattedTotalCost)
               } else {
                   return
               }
           }
        
    }
    private func calculateTotalCost(_ price: Decimal128, _ quantity: Decimal128) -> Decimal128 {
        return price * quantity
    }
    private func updateUI(with totalCost: String) {
            self.callBalanceLabel?(totalCost)
    }
}
//MARK: - TODO: Список задач
// Обновление UI делать не в цикле
// Посчитать разницу в стоимости портфеля за все время
// Сделать возможность отсортировать в алфавитном порядке или по стоимости активов

