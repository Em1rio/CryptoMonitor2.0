//
//  AllCoinsCellModel.swift
//  CryptoMonitorMVVM
//
//  Created by Emir Nasyrov on 08.11.2023.
//

import Foundation

protocol CoinModel {
    var id: String {get}
    var tiker: String {get}
    var nameCoin: String {get}
}

// Модель для биндинга данных при загрузке с сервера
struct AllCoinsCellModel: CoinModel {
    var nameCoin: String
    var tiker: String
    var id: String
    
    init(_ coin: Datum) {
        self.nameCoin = coin.name
        self.tiker = coin.symbol
        self.id = coin.id
    }
    init(nameCoin: String, tiker: String, id: String) {
        self.nameCoin = nameCoin
        self.tiker = tiker
        self.id = id
    }

}
extension AllCoinsCellModel {
    init(_ dbModel: AllCoinsDBModel) {
            self.nameCoin = dbModel.name
            self.tiker = dbModel.symbol
            self.id = dbModel.id
        }
}
