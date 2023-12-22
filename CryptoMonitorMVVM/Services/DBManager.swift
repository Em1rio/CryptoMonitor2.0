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
    func getRealmQuery<T: Object, V: CVarArg>(forType type: T.Type, where attributeName: String, equals value: V) -> Results<T>
    func addTransactionToDatabase(isPurchase: Bool, coinId: String, coinTiker: String, coinsName: String, transaction: String, howManyValue: Decimal128, costValue: Decimal128)
    func saveQuickAccessCoinsToUserDefaults(_ coins: [QuickAccessCoins])
    func loadQuickAccessCoinsFromUserDefaults() -> [QuickAccessCoins]
    func getObject<T: Object>(ofType type: T.Type) -> Results<T>
    
    
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
    /// Сохраняет данные из API в базу данных.
    ///
    /// - Parameter data: Данные типа `AllCoinsDBModel` для сохранения в базе данных.
    ///
    /// - Note: Этот метод используется для сохранения данных из API в базе данных Realm.
    ///         Он принимает данные типа `AllCoinsDBModel` и сохраняет их в базе данных Realm.
    func saveDataFromApi(_ data: AllCoinsDBModel){
        saveData(data)
    }
    /// Сохраняет данные в базе данных Realm.
    ///
    /// - Parameter data: Данные типа `AllCoinsDBModel` для сохранения в базе данных.
    ///
    /// - Note: Этот приватный метод используется для непосредственного сохранения данных
    ///         в базе данных Realm с использованием транзакции записи Realm.
    private func saveData(_ data: AllCoinsDBModel) {
        do {
            try realm.write {
                realm.add(data, update: .modified)
            }
        } catch {
            print("Ошибка при сохранении объекта: \(error)")
        }
    }
    
    /// Дает доступ к извлечению данных о списке всех монет из базы данных Realm.
    ///
    /// - Returns: Массив объектов типа `AllCoinsDBModel` или `nil`, если база данных пуста.
    ///
    /// - Note: Этот  метод дает доступ к извлечению данных о списке всех монет из базы данных Realm.
    ///         Возвращает массив объектов `AllCoinsDBModel` или `nil`, если база данных пуста.
    func fetchFromDatabase() -> [AllCoinsDBModel]? {
        fetchData()
    }
    /// Извлекает данные о всех монетах из базы данных Realm.
    ///
    /// - Returns: Массив объектов типа `AllCoinsDBModel` или `nil`, если база данных пуста.
    ///
    /// - Note: Этот приватный метод извлекает данные список всех монет из базы данных Realm.
    ///         Возвращает массив объектов `AllCoinsDBModel` или `nil`, если база данных пуста.
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
    ///
    /// - Note: Этот метод используется для добавления транзакции в базу данных Realm.
    ///         Он обновляет информацию о количестве монет и их стоимости
    ///         в зависимости от типа транзакции и сохраняет данные в базе данных Realm.
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
                        guard currentCoinQuantity != 0 else {
                            print("Ошибка: Количество монет не может быть отрицательным.")
                            //TODO: Подать сигнал об ошибке пользователю
                            return
                        }
                        
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
                    
                    if isPurchase {
                        parentCategory.coinQuantity = howManyValue
                        parentCategory.totalSpend = howManyValue * costValue
                    } else {
                        guard parentCategory.coinQuantity != nil else {
                            print("Ошибка: Количество монет не может быть отрицательным.")
                    //TODO: Подать сигнал об ошибке пользователю
                            return
                        }
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
    
    /// Сохраняет список быстрого доступа к монетам в пользовательских настройках.
    ///
    /// - Parameter coins: Список объектов типа `QuickAccessCoins` для сохранения в пользовательских настройках.
    ///
    /// - Note: Этот метод используется для сохранения списка быстрого доступа к монетам
    ///         в пользовательских настройках приложения.
    func saveQuickAccessCoinsToUserDefaults(_ coins: [QuickAccessCoins]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(coins) {
            UserDefaults.standard.set(encoded, forKey: "QuickAccessCoins")
        }
    }
    /// Загружает список быстрого доступа к монетам из пользовательских настроек.
    ///
    /// - Returns: Список объектов типа `QuickAccessCoins`, загруженный из пользовательских настроек.
    ///
    /// - Note: Этот метод пытается загрузить список быстрого доступа к монетам из пользовательских настроек
    ///         и возвращает его, если данные были сохранены ранее. В противном случае возвращает значения по умолчанию.
    func loadQuickAccessCoinsFromUserDefaults() -> [QuickAccessCoins] {
        if let savedCoins = UserDefaults.standard.object(forKey: "QuickAccessCoins") as? Data {
            let decoder = JSONDecoder()
            if let loadedCoins = try? decoder.decode([QuickAccessCoins].self, from: savedCoins) {
                return loadedCoins
            }
        }
        return getDefaultQuickAccessCoins()
    }
    
    /// Возвращает массив объектов типа `QuickAccessCoins` со значениями по умолчанию.
    ///
    /// - Returns: Массив объектов типа `QuickAccessCoins` со значениями по умолчанию.
    ///
    /// - Note: Этот метод возвращает массив объектов типа `QuickAccessCoins`,
    ///         содержащих значения по умолчанию для быстрого доступа к монетам.
    private func getDefaultQuickAccessCoins() -> [QuickAccessCoins] {
        return [
            QuickAccessCoins(nameCoin: "Bitcoin", tiker: "BTC", id: "90"),
            QuickAccessCoins(nameCoin: "Ethereum", tiker: "ETH", id: "80"),
            QuickAccessCoins(nameCoin: "Solana", tiker: "SOL", id: "48543"),
        ]
    }
    
    
    //MARK: - Methods for All Assets & Detail Screen
    /// Получает объекты определенного типа из базы данных Realm.
    ///
    /// - Parameter type: Тип объекта, который необходимо получить из базы данных Realm.
    /// - Returns: Результат запроса Realm, содержащий объекты заданного типа.
    ///
    /// - Note: Этот метод извлекает объекты определенного типа из базы данных Realm
    ///         и возвращает их в виде результата запроса Realm.
    func getObject<T: Object>(ofType type: T.Type) -> Results<T> {
        let data = realm.objects(type)
        return data
    }
    
    /// Получает запрос Realm для определенного типа объекта по заданному атрибуту и значению.
    /// - Parameters:
    ///   - type: Тип объекта, для которого необходимо получить запрос Realm.
    ///   - attributeName: Название атрибута, по которому будет выполнен запрос.
    ///   - value: Значение, с которым сравнивается атрибут.
    ///
    /// - Returns: Результат запроса Realm, содержащий объекты заданного типа, удовлетворяющие условию.
    ///
    /// - Note: Этот метод позволяет получить запрос Realm для конкретного типа объекта,
    ///         ограниченного заданным атрибутом и его значением.
    func getRealmQuery<T: Object, V: CVarArg>(forType type: T.Type, where attributeName: String, equals value: V) -> Results<T> {
        let dbObjects = realm.objects(type)
        let realmQuery = dbObjects.filter("\(attributeName) == %@", value)
        return realmQuery
    }
    
    
    
}
