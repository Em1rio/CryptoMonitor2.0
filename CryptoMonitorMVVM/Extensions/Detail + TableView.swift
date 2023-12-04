//
//  Detail + TableView.swift
//  CryptoMonitorMVVM
//
//  Created by Emir Nasyrov on 04.12.2023.
//

import Foundation
import UIKit

extension DetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        cell.contentConfiguration = content
        return cell
    }
    
    
}
