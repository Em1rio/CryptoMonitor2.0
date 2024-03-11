//
//  CoinButtonCell.swift
//  CryptoMonitorMVVM
//
//  Created by Emir Nasyrov on 26.10.2023.
//

import UIKit

final class CoinButtonCell: UICollectionViewCell {
    static let identifire = "CoinButtonCell"
    // MARK: - Variables
    private(set) var quickAccessButtons: QuickAccessCoins!
    
    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20, weight: .regular)
        label.text = "Error"
        return label
    }()
    
    // MARK: - Configure
    public func configure(with quickAccessButtons: QuickAccessCoins) {
        self.quickAccessButtons = quickAccessButtons
        self.titleLabel.text = quickAccessButtons.nameCoin
        self.backgroundColor = .systemGray5
        self.setupUI()
    }
    // MARK: - UI Setup
    private func setupUI() {
        self.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.layer.cornerRadius = 11
        NSLayoutConstraint.activate([
            self.titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.titleLabel.heightAnchor.constraint(equalTo: self.heightAnchor),
            self.titleLabel.widthAnchor.constraint(equalTo: self.widthAnchor),
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.titleLabel.removeFromSuperview()
    }
}
