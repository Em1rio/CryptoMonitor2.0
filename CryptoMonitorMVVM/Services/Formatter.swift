//
//  Formatter.swift
//  CryptoMonitorMVVM
//
//  Created by Emir Nasyrov on 01.12.2023.
//

import Foundation

final class Formatter {

    static let shared = Formatter()

    private init() { }

    func format(_ inputValue: String) -> String {

        let value = Decimal(string: inputValue )
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 16
        return numberFormatter.string(for: value)!
    }
    func formatPercentAndAverage(inputValue: String) -> String {

        let value = Decimal(string: inputValue )
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
        return numberFormatter.string(for: value)!
    }
    func formatCurrency(inputValue: String) -> String {
        let value = Decimal(string: inputValue)
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.locale = Locale(identifier: "es_CL")
        return numberFormatter.string(for: value)!
    }
}
