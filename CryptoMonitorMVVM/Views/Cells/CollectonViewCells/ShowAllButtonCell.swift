//
//  ShowAllButtonCell.swift
//  CryptoMonitorMVVM
//
//  Created by Emir Nasyrov on 02.11.2023.
//

import UIKit

final class ShowAllButtonCell: UICollectionViewCell {
    static let identifire = "ShowAllButtonCell"
    var showAllAction: (() -> Void)?
    
    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.text = "Error"
        return label
    }()
    
    // MARK: - Configure
    public func configure() {
        self.titleLabel.text = "Show All"
        self.backgroundColor = .systemGray5
        self.setupUI()
    }
    
    //MARK: - Action
    @objc func showAllButtonTapped() {
        showAllAction?()
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
