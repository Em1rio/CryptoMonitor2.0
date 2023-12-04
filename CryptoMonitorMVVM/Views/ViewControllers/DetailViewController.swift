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
    //Большая вью с закругленными краями
    //Внутри нее информация о выбранной монете:
    //Рыночная цена отформатированная с $
    //Изменение за 24 часа в %
    //Средняя стоимость активов с $
    //Размер актива(количество)
    //Стоимость на данный момнет в $
    //Изменение за все время в %
    //Сделать таблицу
    // MARK: - UI Components
    private lazy var displayView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemMint
        view.backgroundColor?.withAlphaComponent(0.1)
        view.layer.cornerRadius = 16
        return view
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
        setupDisplayView()
        setupTableView()
    }
    private func setupDisplayView() {
        self.view.addSubview(displayView)
        self.displayView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.displayView.topAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.displayView.leadingAnchor.constraint(
                equalTo: self.view.leadingAnchor, constant: 10),
            self.displayView.trailingAnchor.constraint(
                equalTo: self.view.trailingAnchor, constant: -10),
            self.displayView.heightAnchor.constraint(
                equalTo: self.view.heightAnchor, multiplier: 0.3)
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
    

}
