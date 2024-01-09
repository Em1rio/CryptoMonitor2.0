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
            dateFormatter.dateFormat = "dd.MM.yyyy"
            
            return dateFormatter.string(from: sectionDate)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRow(section)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       tableView.deselectRow(at: indexPath, animated: true)
   }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TransactionCell.identifire, for: indexPath) as? TransactionCell else {
            fatalError("Error")
        }
        let section = indexPath.section
        let row = indexPath.row
            
        guard section < viewModel.sections.count else { return UITableViewCell() }
        let sectionTransactions = viewModel.sections[section].transactions
            
        guard row < sectionTransactions.count else { return UITableViewCell() }
        let buyings = sectionTransactions[row]
        cell.configure(with: buyings)
        cell.transactionLabel.text = buyings.transaction
        
        if let quantity = buyings.quantity {
            let formattedQuantity = Formatter.shared.format("\(quantity)")
            cell.quantityLabel.text = "\(formattedQuantity)"
        }
        if let price = buyings.price {
            let formattedPrice = Formatter.shared.formatCurrencyShort("\(price)")
            cell.priceLabel.text = "\(formattedPrice)"
        }
        let totalCost = viewModel.calcCostOfOnePurchase()
        cell.totalCostLabel.text = Formatter.shared.formatCurrencyShort(totalCost[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Получаем количество ячеек в текущей секции
        let rowsInSection = tableView.numberOfRows(inSection: indexPath.section)
        // Проверяем, является ли ячейка последней в секции
        if indexPath.row == rowsInSection - 1 {
            // Разрешаем редактирование (свайп) для последней ячейки
            return true
        } else {
            // Запрещаем редактирование (свайп) для остальных ячеек
            return false
        }
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] (_, _, completionHandler) in
                guard let self = self else { return }
                // Получаем данные о деталях транзакции
            guard let coin = self.viewModel.getCoin(at: indexPath) else {
                completionHandler(false) // Не удалось найти coin, отменяем удаление
                return
            }
                // Получаем общие данные о криптовалюте
            guard let category = self.viewModel.getCoinCategory(for: coin.coin) else {
                    completionHandler(false) // Не удалось найти категорию, отменяем удаление
                    return
                }
                // Вносим изменения в базу данных
                self.viewModel.makeChangesToDB(coin, category)
                completionHandler(true) // Завершаем удаление ячейки
        }
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .systemRed
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeConfiguration
    }
    //TODO: Реализовать удаление и перерасчет монет
    
    
}
