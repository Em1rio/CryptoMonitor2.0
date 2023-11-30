//
//  DBManager.swift
//  CryptoMonitorMVVM
//
//  Created by Emir Nasyrov on 10.11.2023.
//

import Foundation
import RealmSwift

protocol DBManagerProtocol {
    func saveDataFromApi(_ data: AllCoinsDBModel)
    func fetchFromDatabase() -> [AllCoinsDBModel]?
    func getRealmQuery<T: Object, V>(forType type: T.Type, where keyPath: KeyPath<T, V>, equals value: V) -> Results<T>
    func addTransactionToDatabase(isPurchase: Bool, coinId: String, coinTiker: String, coinsName: String, transaction: String, howManyValue: Decimal128, costValue: Decimal128)
    func saveQuickAccessCoinsToUserDefaults(_ coins: [QuickAccessCoins])
    func loadQuickAccessCoinsFromUserDefaults() -> [QuickAccessCoins]
    func getCoinsAsCategory() -> Results<CoinCategory>
    
    
}

struct DBManager: DBManagerProtocol {
    // MARK: - Variables
    
    private(set) var realm: Realm
    private let quickAccessCoinsKey = "QuickAccessCoinsKey"
    // MARK: - Init
    init() {
        // Инициализация Realm
        do { realm = try Realm() } catch {
            fatalError("Ошибка при инициализации Realm: \(error)")
        }
    }
    
    //MARK: - Methods for All Coins Screen
    func saveDataFromApi(_ data: AllCoinsDBModel){
        saveData(data)
    }
    private func saveData(_ data: AllCoinsDBModel) {
        do {
            try realm.write {
                realm.add(data, update: .modified)
            }
        } catch {
            print("Ошибка при сохранении объекта: \(error)")
        }
    }
    func fetchFromDatabase() -> [AllCoinsDBModel]? {
        fetchData()
    }
    
    private func fetchData() -> [AllCoinsDBModel]? {
        let coins = realm.objects(AllCoinsDBModel.self)
        return coins.isEmpty ? nil : Array(coins)
    }
    
    
    //MARK: - Methods for Main Screen
    
    
    /// Метод для записи транзакции в базу данных
    /// - Parameters:
    ///   - isPurchase: Тип транзакции для идентификации в коде
    ///   - coinId: ID криптовалюты для обращения к API
    ///   - coinTiker: Торговый тикер криптовалюты (BTC, ETH, USDT и тд)
    ///   - coinsName: Название криптовалюты
    ///   - transaction: String значение Покупка или Продажа. Заполняется автоматически
    ///   - howManyValue: Колчество монет
    ///   - costValue: Цена по которой произвелась транзакция
    
    func addTransactionToDatabase(isPurchase: Bool, coinId: String, coinTiker: String, coinsName: String, transaction: String, howManyValue: Decimal128, costValue: Decimal128) {
        let value = EveryBuying(value: ["\(coinsName)", transaction, howManyValue, costValue])
        
        do {
            try realm.write {
                if let parentCategory = realm.object(ofType: CoinCategory.self, forPrimaryKey: coinId) {
                    // Объект с таким Primary Key уже существует, обновляем его
                    var currentCoinQuantity = parentCategory.coinQuantity ?? Decimal128(0)
                    var currentTotalSpend = parentCategory.totalSpend ?? Decimal128(0)
                    
                    if isPurchase {
                        currentCoinQuantity = currentCoinQuantity + howManyValue
                        currentTotalSpend = currentTotalSpend + (howManyValue * costValue)
                    } else {
                        currentCoinQuantity = currentCoinQuantity - howManyValue
                        currentTotalSpend = currentTotalSpend - (howManyValue * costValue)
                    }
                    
                    parentCategory.coinQuantity = currentCoinQuantity
                    parentCategory.totalSpend = currentTotalSpend
                    
                    // Добавляем транзакцию в список coins
                    parentCategory.coins.append(value)
                    
                    realm.add(parentCategory, update: .all)
                    realm.add(value)
                } else {
                    // Объект с таким Primary Key не существует, создаем новый
                    let parentCategory = CoinCategory()
                    parentCategory._id = coinId
                    parentCategory.symbol = coinTiker
                    parentCategory.nameCoin = coinsName
                    let currentCoinQuantity = parentCategory.coinQuantity ?? Decimal128(0)
                    let currentTotalSpend = parentCategory.totalSpend ?? Decimal128(0)
                    
                    if isPurchase {
                        parentCategory.coinQuantity = howManyValue
                        parentCategory.totalSpend = howManyValue * costValue
                    } else {
                        parentCategory.coinQuantity = currentCoinQuantity - howManyValue
                        parentCategory.totalSpend = currentTotalSpend - (howManyValue * costValue)
                    }
                    
                    // Добавляем транзакцию в список coins
                    parentCategory.coins.append(value)
                    
                    realm.add(parentCategory)
                    realm.add(value)
                }
            }
        } catch {
            // Обработка ошибок записи в базу данных
            print("Error writing to database: \(error)")
        }
    }
    
    
    func saveQuickAccessCoinsToUserDefaults(_ coins: [QuickAccessCoins]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(coins) {
            UserDefaults.standard.set(encoded, forKey: "QuickAccessCoins")
        }
    }
    
    func loadQuickAccessCoinsFromUserDefaults() -> [QuickAccessCoins] {
        if let savedCoins = UserDefaults.standard.object(forKey: "QuickAccessCoins") as? Data {
            let decoder = JSONDecoder()
            if let loadedCoins = try? decoder.decode([QuickAccessCoins].self, from: savedCoins) {
                return loadedCoins
            }
        }
        return getDefaultQuickAccessCoins()
    }
    
    // Функция для возврата дефолтных значений
    private func getDefaultQuickAccessCoins() -> [QuickAccessCoins] {
        return [
            QuickAccessCoins(nameCoin: "Bitcoin", tiker: "BTC", id: "90"),
            QuickAccessCoins(nameCoin: "Ethereum", tiker: "ETH", id: "80"),
            QuickAccessCoins(nameCoin: "Solana", tiker: "SOL", id: "48543"),
        ]
    }
    
    
    //MARK: - Methods for All Assets & Detail Screen
    func getCoinsAsCategory() -> Results<CoinCategory> {
        let data = realm.objects(CoinCategory.self)
        return data
    }
    
    func getRealmQuery<T: Object, V>(forType type: T.Type, where keyPath: KeyPath<T, V>, equals value: V) -> Results<T> {
        let dbObjects = realm.objects(type)
        let realmQuery = dbObjects.filter("\(keyPath) == %@", value)
        return realmQuery
    }
    /* EXAMPLE
     let label = "BTC"
     let coinQuery = DatabaseManager.shared.getRealmQuery(forType: EveryBuying.self, where: \.coin, equals: label)
     let value = "Bitcoin"
     let coinCategoryQuery = DatabaseManager.shared.getRealmQuery(forType: CoinCategory.self, where: \.nameCoin, equals: value)
     */
    
    
    
}
