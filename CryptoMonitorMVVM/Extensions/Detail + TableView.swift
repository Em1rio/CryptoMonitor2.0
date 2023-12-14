//
//  Detail + TableView.swift
//  CryptoMonitorMVVM
//
//  Created by Emir Nasyrov on 04.12.2023.
//

import Foundation
import UIKit

extension DetailViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard section < viewModel.sections.count else { return nil }
            
            let sectionDate = viewModel.sections[section].date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy" // Формат даты, который вы хотите отобразить
            
            return dateFormatter.string(from: sectionDate)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRow(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TransactionCell.identifire, for: indexPath) as? TransactionCell else {
            fatalError("Error")
        }
        let buyings = viewModel.buyings[indexPath.row]
        cell.configure(with: buyings)
        cell.transactionLabel.text = buyings.transaction
        
        if let quantity = buyings.quantity {
            let formattedQuantity = Formatter.shared.format("\(quantity)")
            cell.quantityLabel.text = "\(formattedQuantity)"
        }
        if let price = buyings.price {
            let formattedPrice = Formatter.shared.formatCurrency(inputValue: "\(price)")
            cell.priceLabel.text = "\(formattedPrice)"
        }
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
