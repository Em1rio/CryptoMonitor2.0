//
//  AllAssetsViewController + TableView.swift
//  CryptoMonitorMVVM
//
//  Created by Emir Nasyrov on 27.10.2023.
//

import UIKit

extension AllAssetsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRow(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        if let coins = viewModel.coinsAsCategory, !coins.isEmpty  {
            let coin = coins[indexPath.row]
            content.text = coin.nameCoin
        } else {
            
        }
        
        cell.contentConfiguration = content
        return cell
    }
    //TODO: Обработка нажатия на ячейку
    // через замыкание передать данные из детейлVC
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        coordinator?.coordinateToDetail()
    }
    
}
