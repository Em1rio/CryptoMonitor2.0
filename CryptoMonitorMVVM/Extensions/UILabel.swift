//
//  UILabel.swift
//  CryptoMonitorMVVM
//
//  Created by Emir Nasyrov on 06.03.2024.
//

import Foundation
import UIKit
extension UILabel {
    func setTextColorBasedOnValue(_ text: String?) {
        guard let text = text, let value = Double(text.replacingOccurrences(of: ",", with: ".")) else { return }
        
        switch value {
        case let x where x > 0:
            self.textColor = .systemGreen
        case let x where x < 0:
            self.textColor = .systemRed
        default:
            self.textColor = .systemGray
        }
    }
}
