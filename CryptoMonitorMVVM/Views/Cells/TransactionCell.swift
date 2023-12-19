//
//  TransactionCell.swift
//  CryptoMonitorMVVM
//
//  Created by Emir Nasyrov on 13.12.2023.
//

import UIKit

final class TransactionCell: UITableViewCell {
    // MARK: - Variables
    static let identifire = "TransactionCell"
    
    private(set) var transactions: EveryBuying!
    // MARK: - UI Components
    lazy var transactionLabel: UILabel = {
        return createLabel(fontSize: 15)
    }()

    lazy var quantityLabel: UILabel = {
        return createLabel(fontSize: 15)
    }()
    private lazy var descriptionPriceLabel: UILabel = {
       return createLabel(fontSize: 15, text: "Цена:")
    }()
    lazy var priceLabel: UILabel = {
        return createLabel(fontSize: 15)
    }()
    private lazy var descriptionTotalCostLabel: UILabel = {
       return createLabel(fontSize: 15, text: "Итого:")
    }()
    lazy var totalCostLabel: UILabel = {
        return createLabel(fontSize: 15)
    }()
    private lazy var firstStackView: UIStackView = {
        return createStack()
        }()

    private lazy var secondStackView: UIStackView = {
        return createStack()
        }()

    private lazy var thirdStackView: UIStackView = {
        return createStack()
        }()
    // MARK: - Configure
    public func configure(with transactions: EveryBuying) {
        self.transactions = transactions
        
        self.setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
//        self.addSubview(transactionLabel)
//        self.addSubview(quantityLabel)
//        self.addSubview(descriptionPriceLabel)
//        self.addSubview(priceLabel)
//        self.addSubview(descriptionTotalCostLabel)
//        self.addSubview(totalCostLabel)
        self.addSubview(firstStackView)
        addSubview(secondStackView)
        addSubview(thirdStackView)
        firstStackView.translatesAutoresizingMaskIntoConstraints = false
        secondStackView.translatesAutoresizingMaskIntoConstraints = false
        thirdStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
                    firstStackView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1.0/3.0),
                    secondStackView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1.0/3.0),
                    thirdStackView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1.0/3.0),
                    
                    firstStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
                    firstStackView.topAnchor.constraint(equalTo: topAnchor),
                    firstStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
                    firstStackView.trailingAnchor.constraint(equalTo: secondStackView.leadingAnchor),

                    secondStackView.topAnchor.constraint(equalTo: topAnchor),
                    secondStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
                    secondStackView.trailingAnchor.constraint(equalTo: thirdStackView.leadingAnchor),

                    thirdStackView.topAnchor.constraint(equalTo: topAnchor),
                    thirdStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
                    thirdStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
                ])
        let labels1: [UILabel] = [transactionLabel, quantityLabel]
        let labels2: [UILabel] = [descriptionPriceLabel, priceLabel]
        let labels3: [UILabel] = [descriptionTotalCostLabel, totalCostLabel]

        addLabels(labels1, to: firstStackView)
        addLabels(labels2, to: secondStackView)
        addLabels(labels3, to: thirdStackView)
        
        transactionLabel.translatesAutoresizingMaskIntoConstraints = false
        quantityLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionPriceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionPriceLabel.translatesAutoresizingMaskIntoConstraints = false
        totalCostLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
        ])
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    private func addLabels(_ labels: [UILabel], to stackView: UIStackView) {
            labels.forEach { label in
                label.translatesAutoresizingMaskIntoConstraints = false
                stackView.addArrangedSubview(label)
            }
        }
    private func createLabel(fontSize: CGFloat, textColor: UIColor? = UIColor.label, text: String? = "") -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: fontSize)
        label.textAlignment = .center
        label.textColor = textColor
        return label
    }
    private func createStack() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 4
        
        return stackView
    }
}
