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
    func formatCurrency(_ inputValue: String, useCustomFormatting: Bool) -> String {
        guard let value = Decimal(string: inputValue) else {
            return "Invalid input"
        }
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: "es_CL")
        
        switch useCustomFormatting {
        case true:
            numberFormatter.maximumSignificantDigits = 10
            var formattedValue = numberFormatter.string(for: value) ?? "Error formatting"

            // Если число меньше 1 или его длина больше 10, показываем его полностью
            if formattedValue.count > 10 {
                formattedValue = formattedValue.trimmingCharacters(in: .whitespaces)
            } else {
                // Убираем завершающие нули после точки
                let components = formattedValue.components(separatedBy: ".")
                if components.count == 2, let fractionPart = components.last {
                    var trimmedFraction = fractionPart
                    while trimmedFraction.hasSuffix("0") {
                        trimmedFraction = String(trimmedFraction.dropLast())
                    }
                    formattedValue = components.first! + (trimmedFraction.isEmpty ? "" : "." + trimmedFraction)
                }
            }

            return formattedValue
        case false:
            // Стандартное форматирование в стиле валюты
            
            numberFormatter.numberStyle = .currency
            numberFormatter.maximumFractionDigits = 2
            return numberFormatter.string(for: value) ?? "Error formatting"
        }
    }
//    func formatCurrency(inputValue: String) -> String {
//        guard let value = Decimal(string: inputValue) else {
//            return "Invalid input"
//        }
//
//        let numberFormatter = NumberFormatter()
//        numberFormatter.numberStyle = .currency
//        numberFormatter.locale = Locale(identifier: "es_CL")
//        numberFormatter.maximumSignificantDigits = 10
//        var formattedValue = numberFormatter.string(for: value) ?? "Error formatting"
//
//        // Если число меньше 1 или его длина больше 10, показываем его полностью
//        if abs(value) < 1 || formattedValue.count > 10 {
//            formattedValue = formattedValue.trimmingCharacters(in: .whitespaces)
//        } else {
//            // Убираем завершающие нули после точки
//            let components = formattedValue.components(separatedBy: ".")
//            if components.count == 2, let fractionPart = components.last {
//                var trimmedFraction = fractionPart
//                while trimmedFraction.hasSuffix("0") {
//                    trimmedFraction = String(trimmedFraction.dropLast())
//                }
//                formattedValue = components.first! + (trimmedFraction.isEmpty ? "" : "." + trimmedFraction)
//            }
//        }
//
//        return formattedValue
//    }
}
