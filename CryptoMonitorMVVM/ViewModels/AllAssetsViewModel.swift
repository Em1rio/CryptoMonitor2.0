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
    private var initialTotalCost: Decimal128 = 0.0
    private(set) var coinsAsCategory: Results<CoinCategory>?
    var callTableView: (()-> Void)?
    var callBalanceLabel: ((_ totalCost: String,
                            _ moneyProfit: String,
                            _ percentDifference: String) -> Void)?
    
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
    
    //MARK: - Update All Assets Cost & All Time Change Labels
    func updateLabelsData() {
        fetchDataFromDB()
    }
    private func fetchDataFromDB() {
        guard let coins = coinsAsCategory?.toArray(ofType: CoinCategory.self) as? [CoinCategory] else {return}
        prepareAllAssetsCostData(with: coins)
        
    }
    
    private func prepareAllAssetsCostData(with coins: [CoinCategory]) {
        totalCost = 0.0
        var compleatedIterations = 0
        for item in coins {
            fetchData(for: item) {
                compleatedIterations += 1
                if compleatedIterations == coins.count {
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        let formattedTotalCost = Formatter.shared.format("\(self.totalCost)", format: .currencyShort)
                        let profitInfo = prepareAllTimeChangeData(with: coins)
                        self.updateUI(with: formattedTotalCost, and: profitInfo)
                    }
                }
            }
        }
    }
    private func prepareAllTimeChangeData(with coins: [CoinCategory]) -> (String, String) {
        initialTotalCost = 0.0
        for item in coins {
            calculateInitialCostOfAssets(for: item)
        }
        let percentDifference: Decimal128
        var difference: Decimal128 = 0
        if initialTotalCost != 0 {
            percentDifference = ((totalCost - initialTotalCost) / initialTotalCost) * 100
            difference = totalCost - initialTotalCost
        } else {
            percentDifference = 0
        }
        let formatedPercent = Formatter.shared.format("\(percentDifference)", format: .percent)
        let profit = Formatter.shared.format("\(difference)", format: .currencyShort)
        return (formatedPercent, profit)
    }
    private func calculateInitialCostOfAssets(for item: CoinCategory) {
        guard let totalSpend = item.totalSpend  else {return}
        self.initialTotalCost += totalSpend
        
        
    }
    
    
    private func fetchData(for item: CoinCategory, completion: @escaping () -> Void) {
        let idNumber = item._id
        networkManager.fetchTickerDetails(withID: idNumber) { result in
            switch result {
            case .success(let coinData):
                do {
                    let coin = try JSONDecoder().decode([OneCoin].self, from: coinData)
                    self.coinsData(coin)
                } catch {
                    print("Failed to decode coin data with error: \(error)")
                }
            case .failure(let error):
                print("Network request failed with error: \(error)")
            }
            completion()
        }
    }
    
    
    
    
    private func coinsData(_ coin: [OneCoin]) {
        let priceRightNow = try! Decimal128(string: coin.first?.priceUsd ?? "0")
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let coinID = coin.first?.id else { return }
            let realmQuery = getDataFromDB(for: coinID)
            if let quantity = realmQuery.first?.coinQuantity {
                let rawTotalCost = self.calculateTotalCost(priceRightNow, quantity)
                self.totalCost += rawTotalCost
            } else {
                return
            }
        }
    }
    private func getDataFromDB(for id: String) -> Results<CoinCategory>{
        let realmQuery = self.dataBaseManager.getRealmQuery(
            forType: CoinCategory.self,
            where: "_id",
            equals: id)
        return realmQuery
    }
    
    private func calculateTotalCost(_ price: Decimal128, _ quantity: Decimal128) -> Decimal128 {
        return price * quantity
    }
    
    private func updateUI(with totalCost: String, and profit: (String, String)) {
        self.callBalanceLabel?(totalCost, profit.1, profit.0)
        
    }
}
