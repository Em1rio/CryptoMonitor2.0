//
//  DetailViewController.swift
//  CryptoMonitorMVVM
//
//  Created by Emir Nasyrov on 18.10.2023.
//

import UIKit

final class DetailViewController: UIViewController {
    // MARK: - Variables
    private let viewModel: DetailViewModel
    weak var coordinator: DetailCoordinator?
    
    // MARK: - UI Components
    //TODO:
    // Разместить все лейблы во вьюхах
    // Настроить лейблы в таблице

    // MARK: - UI Components
    private lazy var displayView: UIView = {
        return createCustomView(withBackgroundColor: .systemMint, cornerRadius: 16)
    }()
    private lazy var detailsView: UIView = {
        return createCustomView(withBackgroundColor: .systemRed)
    }()

    private lazy var numberOfCoinsLabel: UILabel = {
        return createLabel(withText: "0.00000000 BTC", fontSize: 30)
    }()
    private lazy var coinsValueLabel: UILabel = {
        return createLabel(withText: "= 100000 $", fontSize: 20)
    }()
    private lazy var detailsLabel: UILabel = {
        return createLabel(withText: "Показатели", fontSize: 20)
    }()
    private lazy var averagePriceLabel: UILabel = {
        return createLabel(withText: "$ 25000,0", fontSize: 15)
    }()
    private lazy var changePerDayLabel: UILabel = {
        return createLabel(withText: "+ 100 %", fontSize: 15)
    }()
    private lazy var changeOverTimeLabel: UILabel = {
        return createLabel(withText: "+ 1000 %", fontSize: 15)
    }()
    
    private(set) lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    // MARK: - Lifecycle
    init(_ viewModel: DetailViewModel, coordinator: DetailCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        
    }
    override func viewWillDisappear(_ animated: Bool) {
        coordinator?.navigationController.setNavigationBarHidden(true, animated: false)
    }
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        setupViews()
        setupLabels()
        setupTableView()
    }
    private func setupViews() {
        let averagePriceView = createCustomView(withBackgroundColor: .systemBackground)
        let changeOverTimeView = createCustomView(withBackgroundColor: .systemBackground)
        let changePerDayView = createCustomView(withBackgroundColor: .systemBackground)
        
        self.view.addSubview(displayView)
        self.displayView.addSubview(detailsView)
        self.detailsView.addSubview(averagePriceView)
        self.detailsView.addSubview(changeOverTimeView)
        self.detailsView.addSubview(changePerDayView)
        
        self.displayView.translatesAutoresizingMaskIntoConstraints = false
        self.detailsView.translatesAutoresizingMaskIntoConstraints = false
        averagePriceView.translatesAutoresizingMaskIntoConstraints = false
        changeOverTimeView.translatesAutoresizingMaskIntoConstraints = false
        changePerDayView.translatesAutoresizingMaskIntoConstraints = false
        
        // Создание StackView для размещения view в сетке 2 на 2
            let stackView = UIStackView()
            stackView.axis = .vertical // Ось вертикальная для создания 2 ряда
            stackView.distribution = .fillEqually // Равномерное заполнение по вертикали
            stackView.spacing = 8 // Отступ между view

            // Создание верхнего ряда StackView
            let topRowStackView = UIStackView()
            topRowStackView.axis = .horizontal // Ось горизонтальная для создания 2 столбцов
            topRowStackView.distribution = .fillEqually // Равномерное заполнение по горизонтали
            topRowStackView.spacing = 8 // Отступ между view в ряду

            // Добавление view в верхний ряд StackView
            topRowStackView.addArrangedSubview(averagePriceView)
            topRowStackView.addArrangedSubview(changeOverTimeView)
            // Добавление верхнего ряда в главный StackView
            stackView.addArrangedSubview(changePerDayView)
            
            // Добавление последнего view в нижний ряд StackView
            stackView.addArrangedSubview(topRowStackView)

            // Добавление StackView на detailsView
            detailsView.addSubview(stackView)
            stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.displayView.topAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.displayView.leadingAnchor.constraint(
                equalTo: self.view.leadingAnchor, constant: 10),
            self.displayView.trailingAnchor.constraint(
                equalTo: self.view.trailingAnchor, constant: -10),
            self.displayView.heightAnchor.constraint(
                equalTo: self.view.heightAnchor, multiplier: 0.3),
            
            self.detailsView.centerXAnchor.constraint(equalTo: self.displayView.centerXAnchor),
            self.detailsView.bottomAnchor.constraint(equalTo: self.displayView.bottomAnchor, constant: -10),
            self.detailsView.leadingAnchor.constraint(equalTo: self.displayView.leadingAnchor, constant: 10),
            self.detailsView.trailingAnchor.constraint(equalTo: self.displayView.trailingAnchor, constant: -10),
            self.detailsView.heightAnchor.constraint(equalTo: self.displayView.heightAnchor, multiplier: 0.55),
            
            stackView.topAnchor.constraint(equalTo: detailsView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: detailsView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: detailsView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: detailsView.bottomAnchor)
                
        ])
    
    }
    private func setupLabels() {
        self.displayView.addSubview(numberOfCoinsLabel)
        
        self.displayView.addSubview(coinsValueLabel)
        
        //self.detailsView.addSubview(detailsLabel)
//        self.detailsView.addSubview(averagePriceLabel)
//        self.detailsView.addSubview(changePerDayLabel)
//        self.detailsView.addSubview(changeOverTimeLabel)
        
        self.numberOfCoinsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.coinsValueLabel.translatesAutoresizingMaskIntoConstraints = false
        self.detailsLabel.translatesAutoresizingMaskIntoConstraints = false
        self.averagePriceLabel.translatesAutoresizingMaskIntoConstraints = false
        self.changePerDayLabel.translatesAutoresizingMaskIntoConstraints = false
        self.changeOverTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.numberOfCoinsLabel.centerXAnchor.constraint(equalTo: self.displayView.centerXAnchor),
            self.numberOfCoinsLabel.topAnchor.constraint(equalTo: self.displayView.topAnchor, constant: 10),
            
            self.coinsValueLabel.topAnchor.constraint(equalTo: self.numberOfCoinsLabel.bottomAnchor, constant: 5),
            self.coinsValueLabel.centerXAnchor.constraint(equalTo: self.displayView.centerXAnchor),
            

//            self.detailsLabel.topAnchor.constraint(equalTo: self.detailsView.topAnchor, constant: 5),
//            self.detailsLabel.leadingAnchor.constraint(equalTo: self.detailsView.leadingAnchor, constant: 10),

            
        ])
        
        
        
    }
    
    private func setupTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.view.addSubview(tableView)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.tableView.topAnchor.constraint(
                equalTo: self.displayView.bottomAnchor),
            self.tableView.bottomAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.tableView.leadingAnchor.constraint(
                equalTo: self.view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(
                equalTo: self.view.trailingAnchor)
        ])
    }
    
    private func createLabel(withText text: String, fontSize: CGFloat) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: fontSize)
        label.textAlignment = .center
        return label
        
    }
    private func createCustomView(withBackgroundColor backgroundColor: UIColor, cornerRadius: CGFloat = 0) -> UIView {
        let customView = UIView()
        customView.backgroundColor = backgroundColor
        customView.layer.cornerRadius = cornerRadius
        customView.layer.masksToBounds = cornerRadius > 0
        return customView
    }

}
