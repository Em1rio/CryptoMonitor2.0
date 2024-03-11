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
    enum NumberFormat {
        case standard
        case percent
        case currencyShort
        case currency
    }
    
    func format(_ inputValue: String, format: NumberFormat = .standard) -> String {
        guard let value = Decimal(string: inputValue) else {
            return "Invalid input"
        }
        
        let numberFormatter = NumberFormatter()
        
        switch format {
        case .standard:
            configureNumberFormatter(numberFormatter, style: .decimal, maxDigits: 16)
        case .percent:
            configureNumberFormatter(numberFormatter, style: .decimal, maxDigits: 5)
        case .currencyShort:
            numberFormatter.locale = Locale(identifier: "es_CL")
            configureNumberFormatter(numberFormatter, style: .currency, maxDigits: 5)
            return formatCurrency(value, numberFormatter: numberFormatter)
        case .currency:
            numberFormatter.locale = Locale(identifier: "es_CL")
            configureNumberFormatter(numberFormatter, style: .currency, maxDigits: 10)
            return formatCurrency(value, numberFormatter: numberFormatter)
        }
        
        return numberFormatter.string(for: value) ?? "Error formatting"
    }
    
    private func configureNumberFormatter(_ formatter: NumberFormatter, style: NumberFormatter.Style, maxDigits: Int) {
        formatter.numberStyle = style
        formatter.maximumSignificantDigits = maxDigits
    }
    
    private func formatCurrency(_ value: Decimal, numberFormatter: NumberFormatter) -> String {
        guard var formattedValue = numberFormatter.string(for: value) else {
            return "Error formatting"
        }
        if abs(value) < 1 || formattedValue.count > 10 {
            formattedValue =  formattedValue.trimmingCharacters(in: .whitespaces)
        } else {
            let components = formattedValue.components(separatedBy: ",")
            if components.count == 2, let integerPart = components.first, let fractionPart = components.last {
                var trimmedFraction = fractionPart
                while trimmedFraction.hasSuffix("0") {
                    trimmedFraction = String(trimmedFraction.dropLast())
                }
                let formattedInteger = integerPart.isEmpty ? "0" : integerPart
                formattedValue = formattedInteger + (trimmedFraction.isEmpty ? "" : "," + trimmedFraction)
            }
        }
        return formattedValue
    }
}

