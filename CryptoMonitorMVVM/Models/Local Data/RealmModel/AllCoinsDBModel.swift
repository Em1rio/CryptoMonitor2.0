//
//  AllCoinsDBModel.swift
//  CryptoMonitorMVVM
//
//  Created by Emir Nasyrov on 10.11.2023.
//

import Foundation
import RealmSwift

final class AllCoinsDBModel: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var symbol: String
    @Persisted var name: String
}
