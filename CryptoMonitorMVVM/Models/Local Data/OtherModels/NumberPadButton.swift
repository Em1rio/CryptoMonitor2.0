//
//  NumberPadButton.swift
//  CryptoMonitorMVVM
//
//  Created by Emir Nasyrov on 20.10.2023.
//

import Foundation
import UIKit

enum NumPadButton {
    case allClear
    case decimal
    case number(Int)
    
    init (numpadButton: NumPadButton) {
        
        switch numpadButton {
        case .allClear, .decimal:
            self = numpadButton
        case .number(let int):
            if int.description.count == 1 {
                self = numpadButton
            } else {
                fatalError("NumPadButton.number Int was not 1 digit during init")
            }
        }
    }
}

extension NumPadButton {
    var title: String {
        switch self {
            
        case .allClear:
            return "C"
        case .decimal:
            return "."
        case .number(let int):
            return int.description
        }
    }
    var color: UIColor {
        switch self {
        case .allClear, .decimal, .number:
            return .systemGray5
        }
    }
//    var selectedColor: UIColor? {
//        switch self {
//        case .allClear, .decimal, .number:
//            return .white
//        }
//    }
}
