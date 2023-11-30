//
//  AllAssetsViewController.swift
//  CryptoMonitorMVVM
//
//  Created by Emir Nasyrov on 18.10.2023.
//

import UIKit

final class AllAssetsViewController: UIViewController {
    // MARK: - Variables
    private(set) var viewModel: AllAssetsViewModel
    weak var coordinator: AllAssetsCoordinator?
    
    // MARK: - UI Components
    private(set) lazy var headerView: UIView = {
       let view = UIView()
        view.backgroundColor = .systemBackground
       return view
    }()
    private lazy var allAssetsCostLabel: UILabel = {
        let label = UILabel()
        label.text = "2000"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 40, weight: .regular)
        return label
    }()
    private(set) lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    // MARK: - Lifecycle
    
    init(_ viewModel: AllAssetsViewModel, coordinator: AllAssetsCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
        self.title = "Кошелёк"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupHeaderView()
        setupAllAssetsCostLabel()
        setupTableView()

        
    
    }
    override func viewWillAppear(_ animated: Bool) {
        viewModel.loadDataFromDatabase()
        viewModel.callTableView = { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    // MARK: - UI Setup
    
    private func setupHeaderView() {
        self.view.addSubview(headerView)
        self.headerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            self.headerView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor),
            self.headerView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor),
            self.headerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.2)
        ])
    }
    
    private func setupAllAssetsCostLabel() {
        self.headerView.addSubview(allAssetsCostLabel)
        self.allAssetsCostLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.allAssetsCostLabel.centerXAnchor.constraint(
                    equalTo: headerView.centerXAnchor),
            self.allAssetsCostLabel.centerYAnchor.constraint(
                    equalTo: headerView.centerYAnchor),
            self.allAssetsCostLabel.widthAnchor.constraint(
                    equalTo: headerView.widthAnchor, multiplier: 0.5),
            self.allAssetsCostLabel.heightAnchor.constraint(
                    equalTo: headerView.heightAnchor, multiplier: 0.5)
        ])
    }
    
    private func setupTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.view.addSubview(tableView)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.tableView.topAnchor.constraint(
                equalTo: self.headerView.bottomAnchor),
            self.tableView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            self.tableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor)
        ])
    }
    



}
