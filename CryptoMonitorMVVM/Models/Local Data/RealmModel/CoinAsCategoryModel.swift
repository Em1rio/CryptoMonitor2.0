//
//  CoinAsCategoryModel.swift
//  CryptoMonitorMVVM
//
//  Created by Emir Nasyrov on 10.11.2023.
//

import Foundation
import RealmSwift



final class CoinCategory: Object {
    @Persisted(primaryKey: true) var _id: String
    @Persisted var symbol: String
    @Persisted var nameCoin: String
    @Persisted var coinQuantity: Decimal128?
    @Persisted var totalSpend: Decimal128?
    @Persisted var index: Int = 0
    
    @Persisted var coins: List<EveryBuying>
}

final class EveryBuying: Object {
    @Persisted var coin: String
    @Persisted var transaction: String
    @Persisted var quantity: Decimal128?
    @Persisted var price: Decimal128?
    @Persisted var date: Date = Date()
    
    @Persisted(originProperty: "coins") var assignee: LinkingObjects<CoinCategory>
}
