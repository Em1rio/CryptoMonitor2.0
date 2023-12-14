//
//  DetailViewModel.swift
//  CryptoMonitorMVVM
//
//  Created by Emir Nasyrov on 18.10.2023.
//

import Foundation
import RealmSwift
struct TransactionSection {
    var date: Date
    var transactions: [EveryBuying]
}
final class DetailViewModel {
    //TODO:
    //ЗАпрос маркет прайса
    //Высчитать среднюю
   // Настроить таблицу  в которой будут все покупки по выбранному id или имени
    //Высота ячейки 60
    //Удаление транзацкии и переасчет стоимости актива
    // Форматировать дату для использования ее в качестве секции в транзакциях
    
    // MARK: - Variables
    private let networkManager: NetworkManagerProtocol
    private let dataBaseManager: DBManagerProtocol
    private var dataByDate: [Date: [EveryBuying]] = [:]
    var buyings: [EveryBuying] = []
     var sections: [TransactionSection] = []
    var callBalanceLabel: ((_ totalCost: String) -> Void)?
    var callTableView: (()-> Void)?
    private var totalCost: Decimal128 = 0.0
    var nameCoin: String = ""
    // MARK: - Lifecycle
    init(_ networkManager: NetworkManagerProtocol,
         _ dataBaseManager: DBManagerProtocol) {
        self.networkManager = networkManager
        self.dataBaseManager = dataBaseManager
    }
    
    public func getDetailData() {
        fetchDataFromDB()
        fetchMarketSituation()
        getAveragePrice() //Пока что только принт

    }
    
    private func fetchDataFromDB() {
        let filteredBuyings = dataBaseManager.getRealmQuery(
            forType: EveryBuying.self,
            where: "coin",
            equals: nameCoin)
        buyings = Array(filteredBuyings)
    }
    
    func numberOfSections() -> Int {
        return buyings.count
    }
    
    func numberOfRow(_ section: Int) -> Int {
        let groupedTransactions = Dictionary(grouping: buyings, by: { Calendar.current.startOfDay(for: $0.date) })
        sections = groupedTransactions.map { TransactionSection(date: $0.key, transactions: $0.value) }
        sections.sort { $0.date < $1.date }
        return sections.count

    }

    private func getAveragePrice() {
        let data = dataBaseManager.getRealmQuery(forType: CoinCategory.self, where: "nameCoin", equals: nameCoin)
            guard let firstData = data.first else {
                print("Нет данных для \(nameCoin)")
                return
            }
            guard let quantity = firstData.coinQuantity?.decimalValue,
                  let price = firstData.totalSpend?.decimalValue,
                  quantity != 0 else {
                print("Недостаточно данных для расчета средней цены")
                return
            }
            let avrgPrice = price / quantity
        print("Средняя цена: \(Formatter.shared.formatCurrency(inputValue: "\(avrgPrice)"))")
        
    }
    private func fetchMarketSituation() {
        let data = dataBaseManager.getRealmQuery(forType: CoinCategory.self, where: "nameCoin", equals: nameCoin)
        guard let firstData = data.first else {
            print("Нет данных для \(nameCoin)")
            return
        }
        let coinId = firstData._id
        fetchData(for: coinId)
    }
    private func fetchData(for id: String) {
         networkManager.fetchTickerDetails(withID: id) { result in
         switch result {
                 case .success(let coinData):
                     do {
                         let coin = try JSONDecoder().decode([OneCoin].self, from: coinData)
                         self.prepareData(coin)
                     } catch {
                         print("Failed to decode coin data with error: \(error)")
                     }
                 case .failure(let error):
                     print("Network request failed with error: \(error)")
                 }
             }
     }
     
    private func prepareData(_ coin: [OneCoin]) {
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
                    let formattedTotalCost = Formatter.shared.formatCurrency(inputValue: "\(self.totalCost)")
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
