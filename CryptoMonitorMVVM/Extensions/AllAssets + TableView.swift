//
//  AllAssetsViewController + TableView.swift
//  CryptoMonitorMVVM
//
//  Created by Emir Nasyrov on 27.10.2023.
//

import UIKit

extension AllAssetsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let coins = viewModel.allAssetsModel[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = coins
        cell.contentConfiguration = content
        return cell
    }

    
    
}
