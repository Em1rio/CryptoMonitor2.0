//
//  DetailViewModel.swift
//  CryptoMonitorMVVM
//
//  Created by Emir Nasyrov on 18.10.2023.
//

import Foundation
import RealmSwift

final class DetailViewModel {
    //TODO:
    //Удаление транзацкии и переасчет стоимости актива
    //Уведомлять о том что нет интренета и поэтому показываны N/A
    //Основной лейбл и средняя цена
    // MARK: - Variables
    private let networkManager: NetworkManagerProtocol
    private let dataBaseManager: DBManagerProtocol
    private var dataByDate: [Date: [EveryBuying]] = [:]
    var buyings: [EveryBuying] = []
    var sections: [TransactionSection] = []
    var callBalanceAndOtherDBLabels: ((_ balance: String, _ avrgPrice: String) -> Void)?
    var callMarketDataLabels: ((_ cost: String, _ marketPrice: String,
                                _ changeOverTime: String, _ changePerDay: String ) -> Void)?
    var callTableView: (()-> Void)?
    var nameCoin: String = ""
    var id: String = ""
    var tiker: String = ""
    // MARK: - Lifecycle
    init(_ networkManager: NetworkManagerProtocol,
         _ dataBaseManager: DBManagerProtocol) {
        self.networkManager = networkManager
        self.dataBaseManager = dataBaseManager
    }
    
    public func getDetailData() {
        getGeneralData()
        getTransactionsDetailsFromDB()
        getMarketSituation()
        

    }
    //MARK: - Get Quantity and Average price from Database
    private func getGeneralData() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            let data = self.dataBaseManager.getRealmQuery(
            forType: CoinCategory.self,
            where: "nameCoin",
            equals: self.nameCoin)
        guard let firstData = data.first else {
            print("Нет данных для \(self.nameCoin)")
                return
            }
        guard let quantity = firstData.coinQuantity?.decimalValue,
                  let price = firstData.totalSpend?.decimalValue,
                  quantity != 0 else {
            self.updateStorageDataUI(with: "0", and: "0")
                print("Недостаточно данных для расчета средней цены")
                return
            }
        let avrgPrice = price / quantity
        self.tiker = firstData.symbol
        self.id = firstData._id
        let formattedQuantity = Formatter.shared.format("\(quantity)")
        let formattedAvrgPrice = Formatter.shared.formatCurrencyShort("\(avrgPrice)")
        self.updateStorageDataUI(with: "\(formattedQuantity) \(self.tiker)", and: "\(formattedAvrgPrice)")
        }
    }
    //MARK: - Updating UI with data from database
    private func updateStorageDataUI(with quanntity: String, and avrgPrice: String) {
        self.callBalanceAndOtherDBLabels?(quanntity, avrgPrice)
     }
    //MARK: - Requesting current prices from the server for a selected item
    private func getMarketSituation() {
        let data = dataBaseManager.getRealmQuery(forType: CoinCategory.self, where: "nameCoin", equals: nameCoin)
        guard let firstData = data.first else {
            print("Нет данных для \(nameCoin)")
            return
        }
        let coinId = firstData._id
        fetchData(for: coinId)
    }
    //MARK: - API request processing
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
    //MARK: - Preparing data for display
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
                    let formattedPrice = Formatter.shared.formatCurrency("\(priceRightNow)")
                    let formattedTotalCost = Formatter.shared.formatCurrencyShort("\(rawTotalCost)")
                    guard let totalSpend = realmQuery.first?.totalSpend else {
                               let changeOverTime = "N/A"
                               self.updateMarketDataUI(
                                   total: "≈ \(formattedTotalCost)",
                                   price: formattedPrice,
                                   change: changeOverTime,
                                   change24: coin.first?.percentChange24H ?? "N/A")
                               return
                           }
                    let changeOverTime = self.calculatePercentageChange(
                        priceRightNow, totalSpend, quantity)
                     self.updateMarketDataUI(
                        total: "≈ \(formattedTotalCost)",
                        price: formattedPrice,
                        change: changeOverTime,
                        change24: coin.first?.percentChange24H ?? "N/A")
                } else {
                    return
                }
            }
         
     }
    //MARK: - Calculate percentage change over time
    private func calculatePercentageChange(_ price:Decimal128, _ totalSpend: Decimal128, _ quantity: Decimal128 ) -> String {
        guard totalSpend != 0 && quantity != 0 else { return "\(Decimal128.zero)" }
        let data = (price - (totalSpend / quantity)) / (totalSpend / quantity) * 100
        if data < 0 {
            let changeOverTime = Formatter.shared.formatPercentAndAverage(inputValue: "\(data)")
            return "\(changeOverTime)"
        } else {
            let changeOverTime = Formatter.shared.formatPercentAndAverage(inputValue: "\(data)")
            return "+\(changeOverTime)"
        }
    }
    //MARK: - Calculating the total value of an asset
     private func calculateTotalCost(_ price: Decimal128, _ quantity: Decimal128) -> Decimal128 {
         return price * quantity
     }
    //MARK: - Updating UI with data from API
    private func updateMarketDataUI(total totalCost: String, price priceRightNow: String, change overTime: String, change24 perDay: String) {
        self.callMarketDataLabels?(totalCost, priceRightNow, overTime, perDay)
     }
    //MARK: - Get all transactions from database and group by date
    private func getTransactionsDetailsFromDB() {
        let filteredBuyings = dataBaseManager.getRealmQuery(
            forType: EveryBuying.self,
            where: "coin",
            equals: nameCoin)
        buyings = Array(filteredBuyings)
        groupTransactionsByDate()
    }
    //MARK: - Grouping method by date
    private func groupTransactionsByDate() {
        let groupedTransactions = Dictionary(grouping: buyings, by: { Calendar.current.startOfDay(for: $0.date) })
        sections = groupedTransactions.map { TransactionSection(date: $0.key, transactions: $0.value) }
        sections.sort { $0.date < $1.date }
    }
    //MARK: - Data for tableView: Sections
    func numberOfSections() -> Int {
        return sections.count
    }
    //MARK: - Data for tableView: Rows
    func numberOfRow(_ section: Int) -> Int {
        guard section < sections.count else { return 0 }
            return sections[section].transactions.count
    }
    //MARK: - Data for tableView: Calculation of the total transaction price
    func calcCostOfOnePurchase() -> [String] {
        return buyings.compactMap { buying in
            guard let price = buying.price, let quantity = buying.quantity else {
                return nil
            }
            let totalCost = price * quantity
            return "\(totalCost)"
        }
    }

    func getCoin(at indexPath: IndexPath) -> EveryBuying? {
        guard indexPath.row < buyings.count else { return nil }
            let buying = buyings[indexPath.row]
            return buying
    }
    func getCoinCategory(for name: String) -> CoinCategory? {
        let coinCategory = dataBaseManager.getObject(ofType: CoinCategory.self).filter("nameCoin == %@", name).first
            return coinCategory
    }
  
    func makeChangesToDB(_ buyings: EveryBuying, _ category: CoinCategory) {
        let coin = buyings
        let category = category
        dataBaseManager.addAndDeleteRealmData(coin, category)
        getDetailData()
        callTableView?()
    }


}
