//
//  NumberPadCell.swift
//  CryptoMonitorMVVM
//
//  Created by Emir Nasyrov on 20.10.2023.
//

import UIKit

class NumberPadCell: UICollectionViewCell {
    static let identifire = "NumberPadCell"
    
    // MARK: - Variables
    private(set) var numPadButton: NumPadButton!
    
    // MARK: - UI Components
    private let titleLabel: UILabel = {
       let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 40, weight: .regular)
        label.text = "Error"
        return label
    }()
    
    // MARK: - Configure
    public func configure(with numPadButton: NumPadButton) {
        self.numPadButton = numPadButton
        self.titleLabel.text = numPadButton.title
        self.backgroundColor = .systemGray5
        
        switch numPadButton {
        case .allClear:
            self.titleLabel.textColor = .systemRed
        default:
            break
        }
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

