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
    var isFirstInteractionWithNumPad = true
    private(set) var canAddDecimal: Bool = true
    private(set) var accumulatedValue: Double = 0
    private(set) var cellDataSource: Observable<[QuickAccessCoins]> = Observable([])
    private(set) var quickAccessCoins: [QuickAccessCoins]?
    private(set) var quickAccessCoinsCells: [QuickAccessCoins] = []

    
    // MARK: - Lifecycle
    init(_ networkManager: NetworkManagerProtocol,
         _ dataBaseManager: DBManagerProtocol) {
        self.networkManager = networkManager
        self.dataBaseManager = dataBaseManager
        loadQuickAccessCoins()
    }
    
    
    // MARK: - CollectionView DataSourse Array
    //TODO: Изменять цвет при нажатии и возврат обратно
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
    
    func numPadButtonTapped(_ buttonCell: NumPadButton, forSegmentIndex selectedSegmentIndex: Int, observableToUpdate: inout Observable<String>) {
        if case .allClear = buttonCell {
            accumulatedValue = 0.0
            canAddDecimal = true
            isFirstInteractionWithNumPad = true
            observableToUpdate.value = "0.0"
        } else {
            if observableToUpdate.value?.count ?? 0 < 10 {
                // Обработка нажатия кнопки дроби
                if case .decimal = buttonCell {
                    if canAddDecimal && !(observableToUpdate.value?.contains(".") ?? false) {
                        if let currentValue = observableToUpdate.value {
                            observableToUpdate.value = currentValue + "."
                        }
                    }
                }
                // Обработка нажатия номерных кнопок
                else if case .number(let number) = buttonCell {
                    if isFirstInteractionWithNumPad && observableToUpdate.value == "0.0" {
                        observableToUpdate.value = "\(number)"
                        isFirstInteractionWithNumPad = false
                    }  else if observableToUpdate.value == "0" && number != 0 {
                        observableToUpdate.value = "\(number)"
                    } else  {
                        if observableToUpdate.value == "0" && number == 0 {
                            observableToUpdate.value = "0.0"
                        } else {
                            observableToUpdate.value = (observableToUpdate.value ?? "") + "\(number)"
                        }
                    }
                }
            }
        }
    }
    
    
    
}
