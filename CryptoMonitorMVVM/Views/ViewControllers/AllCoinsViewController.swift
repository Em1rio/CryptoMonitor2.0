//
//  AllCoinsViewController.swift
//  CryptoMonitorMVVM
//
//  Created by Emir Nasyrov on 18.10.2023.
//

import UIKit

final class AllCoinsViewController: UIViewController {
    // MARK: - Variables
    private let viewModel: AllCoinsViewModel
    weak var coordinator: AllCoinsCoordinator?
    private var cellDataSource = [AllCoinsCellModel]()
    private let activityIndicator = UIActivityIndicatorView()
    var dataFromSelected: ((AllCoinsCellModel) -> Void)?


    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    // MARK: - Lifecycle
    init(_ viewModel: AllCoinsViewModel, coordinator: AllCoinsCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTableView()
        setupIndicator()
        bindViewModel()
        viewModel.loadData()
        
        


        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        coordinator?.didFinish()
    }
    deinit {

    }
    // MARK: - Actions

    private func bindViewModel() {
        viewModel.isBadConnection.bind { [weak self] isBadConnection in
            guard let self else {return}
            DispatchQueue.main.async {
                self.showNoInternetConnectionAlert()
            }
        }
        
        viewModel.isLoading.bind { [weak self] isLoading in
            guard let self, let isLoading else {return}
            DispatchQueue.main.async {
            isLoading ? self.activityIndicator.startAnimating() : self.activityIndicator.stopAnimating()
            }
        }
        viewModel.cellDataSource.bind { [weak self] AllCoinsCellModel in
            guard let self, let AllCoinsCellModel else {return}
            self.cellDataSource = AllCoinsCellModel
            self.reloadData()
        }
    }
    private func checkInternetConnection() {
        
    }
    private func showNoInternetConnectionAlert() {
        let alert = UIAlertController(
            title: "Нет соединения", message: "Требуется подключение к интернету для загрузки данных", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    
    // MARK: - Setup UI
    private func setupTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.view.addSubview(tableView)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.tableView.topAnchor.constraint(
                equalTo: self.view.topAnchor),
            self.tableView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            self.tableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor)
        ])
    }
    private func setupIndicator() {
        self.view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            self.activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

extension AllCoinsViewController: UITableViewDelegate, UITableViewDataSource {
    func reloadData() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRow(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let coins = cellDataSource[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = coins.nameCoin
        content.secondaryText = coins.tiker
        cell.contentConfiguration = content
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = cellDataSource[indexPath.row]
        dataFromSelected?(selectedItem)
        self.dismiss(animated: true, completion: nil)
    }
}

