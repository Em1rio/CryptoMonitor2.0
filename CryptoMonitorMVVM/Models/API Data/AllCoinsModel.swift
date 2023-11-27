//
//  AllCoinsModel.swift
//  CryptoMonitorMVVM
//
//  Created by Emir Nasyrov on 20.10.2023.
//

import Foundation

// MARK: - AllCoins
struct AllCoins: Decodable {
    let data: [Datum]
    
}

// MARK: - Datum
struct Datum: Decodable {
    let id, symbol, name, nameid: String
    let rank: Int
    let priceUsd, percentChange24H, percentChange1H, percentChange7D: String
    let priceBtc, marketCapUsd: String
    let volume24, volume24A: Double
    let csupply: String
    let tsupply, msupply: String?

    enum CodingKeys: String, CodingKey {
        case id, symbol, name, nameid, rank
        case priceUsd = "price_usd"
        case percentChange24H = "percent_change_24h"
        case percentChange1H = "percent_change_1h"
        case percentChange7D = "percent_change_7d"
        case priceBtc = "price_btc"
        case marketCapUsd = "market_cap_usd"
        case volume24
        case volume24A = "volume24a"
        case csupply, tsupply, msupply
    }
}
