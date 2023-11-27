//
//  MainViewModel.swift
//  CryptoMonitorMVVM
//
//  Created by Emir Nasyrov on 18.10.2023.
//

import Foundation
import RealmSwift



final class MainViewModel {
    // MARK: - Variables
    private let networkManager: NetworkManagerProtocol
    private let dataBaseManager: DBManagerProtocol
    var cellDataSource: Observable<[QuickAccessCoins]> = Observable([])
    var quickAccessCoins: [QuickAccessCoins]?
    var canAddDecimal: Bool = true
    var isFirstInteractionWithNumPad = true
    var accumulatedValue: Double = 0
    var quickAccessCoinsCells: [QuickAccessCoins] = []
  //  var isPurchase: Observable<Bool> = Observable(true)

    // MARK: - Lifecycle
    init(_ networkManager: NetworkManagerProtocol,
         _ dataBaseManager: DBManagerProtocol) {
        self.networkManager = networkManager
        self.dataBaseManager = dataBaseManager
        loadQuickAccessCoins()
    }


    // MARK: - CollectionView DataSourse Array
    //TODO: Изменять цвет при нажатии и вохврат обратно
    let numPadButtonCells: [NumPadButton] = [
        .number(7), .number(8), .number(9),
        .number(4), .number(5), .number(6),
        .number(1), .number(2), .number(3),
        .decimal, .number(0), .allClear
    ]
    
    private func loadQuickAccessCoins() {
            quickAccessCoinsCells = dataBaseManager.loadQuickAccessCoinsFromUserDefaults()
            cellDataSource.value = quickAccessCoinsCells
        }
    //AllCoinsCellModel
    func saveToDataBase<T: CoinModel>(_ data: T, isPurchase: Bool, quantity: Decimal128, price: Decimal128) {
        let coinId = data.id
        let coinTiker = data.tiker
        let coinsName = data.nameCoin
        var transaction: String {
            if isPurchase == true {
                return "Покупка"
            } else {
                return "Продажа"
            }
        }
        dataBaseManager.addTransactionToDatabase(isPurchase: isPurchase, coinId: coinId, coinTiker: coinTiker, coinsName: coinsName, transaction: transaction, howManyValue: quantity, costValue: price)
        let updatedCoins = updateQuickAccessCoins(newCoin: QuickAccessCoins(nameCoin: data.nameCoin, tiker: data.tiker, id: data.id))
                quickAccessCoinsCells = updatedCoins // Обновление основного массива
                cellDataSource.value = updatedCoins // Обновление данных для обновления UI
        dataBaseManager.saveQuickAccessCoinsToUserDefaults(updatedCoins)
        print(cellDataSource)
        
    }
    func updateQuickAccessCoins(newCoin: QuickAccessCoins) -> [QuickAccessCoins] {
        var updatedCoins = quickAccessCoinsCells
        
        if let existingIndex = updatedCoins.firstIndex(where: { $0.nameCoin == newCoin.nameCoin }) {
            let existingCoin = updatedCoins.remove(at: existingIndex)
            updatedCoins.insert(existingCoin, at: 0)
        } else {
            if updatedCoins.count < 5 {
                updatedCoins.insert(newCoin, at: 0)
            } else {
                updatedCoins.removeLast()
                updatedCoins.insert(newCoin, at: 0)
            }
        }
        dataBaseManager.saveQuickAccessCoinsToUserDefaults(updatedCoins)
        return updatedCoins
    }
}
