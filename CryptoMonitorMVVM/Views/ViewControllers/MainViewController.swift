//
//  ViewController.swift
//  CryptoMonitorMVVM
//
//  Created by Emir Nasyrov on 18.10.2023.
//

import UIKit


final class MainViewController: UIViewController {
    
    // MARK: - Variables
    private(set) var viewModel: MainViewModel
    weak var coordinator: MainCoordinator?
    private var cellDataSource = [QuickAccessCoins]()
    private let color = CABasicAnimation(keyPath: "borderColor")
    let quantityLabelObservable = Observable<String>("0.0")
    let priceLabelObservable = Observable<String>("0.0")
    var isPurchase = true

    
    var containerForData: String = ""
    // MARK: - UI Components
    private let SellOrBuyMode: UISegmentedControl = {
        let segmentControl = UISegmentedControl()
        segmentControl.insertSegment(withTitle: "Купил", at: 0, animated: true)
        segmentControl.insertSegment(withTitle: "Продал", at: 1, animated: true)
        segmentControl.selectedSegmentIndex = 0
        segmentControl.selectedSegmentTintColor = .systemGray5
       
        return segmentControl
    }()
    
    private let displayView: UIView = {
       let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.green.cgColor
        view.layer.cornerRadius = 16
        return view
    }()
    private let quantityLabel: UILabel = {
        let label = UILabel()
        label.text = "0.0"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20, weight: .regular)
        label.setContentHuggingPriority(UILayoutPriority(250), for: .horizontal)

        return label
    }()
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.text = "0.0"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20, weight: .regular)
        label.textColor = .systemGray
        return label
    }()
    
    private(set) var LabelSelection: UISegmentedControl = {
        
        let segmentControl = UISegmentedControl()
        segmentControl.insertSegment(withTitle: "Количество", at: 0, animated: true)
        segmentControl.insertSegment(withTitle: "Цена", at: 1, animated: true)
        segmentControl.selectedSegmentIndex = 0
        segmentControl.selectedSegmentTintColor = .systemGray5
        return segmentControl
    }()
    
    private let numPadContainerView: UIView = {
       let view = UIView()
        return view
    }()
    public var numPadContainerSize: CGSize {
        return numPadContainerView.frame.size
        }
    
    private(set) var numPadCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.register(NumberPadCell.self, forCellWithReuseIdentifier: NumberPadCell.identifire)
        return collectionView
    }()
    private let coinContainerView: UIView = {
        let view = UIView()
        return view
    }()
    public var coinContainerViewSize: CGSize {
        return coinContainerView.frame.size
        }
    private(set) var coinCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let coinCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        coinCollectionView.backgroundColor = .systemBackground
        coinCollectionView.register(CoinButtonCell.self, forCellWithReuseIdentifier: CoinButtonCell.identifire)
        coinCollectionView.register(ShowAllButtonCell.self, forCellWithReuseIdentifier: ShowAllButtonCell.identifire)
        return coinCollectionView
    }()
    
    // MARK: - Lifecycle



    init(_ viewModel: MainViewModel, coordinator: MainCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        
        super.init(nibName: nil, bundle: nil)
        self.title = "Запись"
    }
    
    required init?(coder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindLabels()
        bindQuickAccessButtons()
    }

    
    // MARK: - Actions
    @objc func sellOrBuyModeValueChanged() {
        let selectedSegmentIndex = SellOrBuyMode.selectedSegmentIndex
        switch selectedSegmentIndex {
        case 0:
            color.fromValue = UIColor.red.cgColor
            color.toValue = UIColor.systemGreen.cgColor
            color.duration = 1
            color.repeatCount = 1
            displayView.layer.borderWidth = 2
            displayView.layer.borderColor = UIColor.systemGreen.cgColor
            displayView.layer.add(color, forKey: "borderColor")
            isPurchase = true
        case 1:
            color.fromValue = UIColor.systemGreen.cgColor
            color.toValue = UIColor.red.cgColor
            color.duration = 1
            color.repeatCount = 1
            displayView.layer.borderWidth = 2
            displayView.layer.borderColor = UIColor.red.cgColor
            displayView.layer.add(color, forKey: "borderColor")
            isPurchase = false
        default:
            break
        }
    
    }
    
    @objc func labelSelectionValueChanged() {
  
        let selectedSegmentIndex = LabelSelection.selectedSegmentIndex
        
        switch selectedSegmentIndex {
        case 0:
            quantityLabel.textColor = .label
            priceLabel.textColor = .systemGray
            self.viewModel.isFirstInteractionWithNumPad = true
          
        case 1:
            quantityLabel.textColor = .systemGray
            priceLabel.textColor = .label
            self.viewModel.isFirstInteractionWithNumPad = true
           
        default:
            break
        }
    
    }
    func setLabelsOnDefaultState() {
        self.LabelSelection.selectedSegmentIndex = 0
        self.labelSelectionValueChanged()
        self.quantityLabelObservable.value = "0.0"
        self.priceLabelObservable.value = "0.0"
    }
    private func bindLabels() {
        quantityLabelObservable.bind { [weak self] text in
            self?.quantityLabel.text = text
        }

        priceLabelObservable.bind { [weak self] text in
            self?.priceLabel.text = text
        }
    }
    private func bindQuickAccessButtons() {
        viewModel.cellDataSource.bind { [weak self] QuickAccessCoins  in
            guard let self, let QuickAccessCoins else {return}
            self.cellDataSource = QuickAccessCoins
            self.coinCollectionView.reloadData()
        }
    }


    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        setupSellOrBuyMode()
        setupDisplayView()
        setupLabels()
        setupLabelSelection()
        setupNumPadContainerView()
        setupNumPadCollectionView()
        setupCoinContainerView()
        setupCoinCollectionView()
    }
    
    private func setupSellOrBuyMode() {
        self.view.addSubview(SellOrBuyMode)
        self.SellOrBuyMode.addTarget(self, action: #selector(sellOrBuyModeValueChanged), for: .valueChanged)
        self.SellOrBuyMode.translatesAutoresizingMaskIntoConstraints = false
//        let spacingFromTop = view.bounds.height * 0.015
        
        NSLayoutConstraint.activate([
            self.SellOrBuyMode.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            self.SellOrBuyMode.leadingAnchor.constraint(
                lessThanOrEqualTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 285),
            self.SellOrBuyMode.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10)
        ])
    }
    private func setupDisplayView() {
        self.view.addSubview(displayView)
        self.displayView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.displayView.topAnchor.constraint(
                lessThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            self.displayView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 26),
            self.displayView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -26),
            self.displayView.heightAnchor.constraint(
                equalTo: view.heightAnchor, multiplier: 0.1)
        ])
    }
    private func setupLabels() {
        self.displayView.addSubview(quantityLabel)
        self.displayView.addSubview(priceLabel)
        quantityLabel.text = quantityLabelObservable.value
        priceLabel.text = priceLabelObservable.value
        
        self.quantityLabel.translatesAutoresizingMaskIntoConstraints = false
        self.priceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.quantityLabel.centerYAnchor.constraint(equalTo: self.displayView.centerYAnchor),
            self.quantityLabel.leadingAnchor.constraint(equalTo: self.displayView.leadingAnchor, constant: 8),
            self.quantityLabel.widthAnchor.constraint(greaterThanOrEqualTo: self.displayView.widthAnchor, multiplier: 0.5),
            
            self.priceLabel.centerYAnchor.constraint(equalTo: self.displayView.centerYAnchor),
            self.priceLabel.trailingAnchor.constraint(equalTo:  self.displayView.trailingAnchor, constant: -8),
            self.priceLabel.widthAnchor.constraint(greaterThanOrEqualTo: self.displayView.widthAnchor, multiplier: 0.5),
            
        ])
    }
    private func setupLabelSelection() {
        self.view.addSubview(LabelSelection)
        self.LabelSelection.addTarget(self, action: #selector(labelSelectionValueChanged), for: .valueChanged)
        self.LabelSelection.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.LabelSelection.topAnchor.constraint(
                equalTo: displayView.bottomAnchor, constant: 5),
            self.LabelSelection.leadingAnchor.constraint(
                lessThanOrEqualTo: view.leadingAnchor, constant: 93),
            self.LabelSelection.trailingAnchor.constraint(
                lessThanOrEqualTo: view.trailingAnchor, constant: -93),
            self.LabelSelection.heightAnchor.constraint(
                equalTo: view.heightAnchor, multiplier: 0.0464768),
            self.LabelSelection.centerXAnchor.constraint(
                equalTo: displayView.centerXAnchor),
            
        ])
    }
    private func setupNumPadContainerView() {
        self.view.addSubview(numPadContainerView)
        self.numPadContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.numPadContainerView.centerXAnchor.constraint(
                equalTo: view.centerXAnchor),
            self.numPadContainerView.centerYAnchor.constraint(
                equalTo: view.centerYAnchor),
            self.numPadContainerView.widthAnchor.constraint(
                equalTo: view.widthAnchor, multiplier: 0.7),
            self.numPadContainerView.heightAnchor.constraint(
                equalTo: view.heightAnchor, multiplier: 0.4)
        ])
    }
    private func setupNumPadCollectionView() {
        self.numPadCollectionView.dataSource = self
        self.numPadCollectionView.delegate = self
        numPadContainerView.addSubview(numPadCollectionView)
        self.numPadCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.numPadCollectionView.leadingAnchor.constraint(
                equalTo: self.numPadContainerView.leadingAnchor),
            self.numPadCollectionView.trailingAnchor.constraint(
                equalTo: self.numPadContainerView.trailingAnchor),
            self.numPadCollectionView.topAnchor.constraint(
                equalTo: self.numPadContainerView.topAnchor),
            self.numPadCollectionView.bottomAnchor.constraint(
                equalTo: self.numPadContainerView.bottomAnchor)
        ])
    }
    
    private func setupCoinContainerView() {
        self.view.addSubview(coinContainerView)
        self.coinContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.coinContainerView.bottomAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -25 ),
            self.coinContainerView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 26),
            self.coinContainerView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -26),
            self.coinContainerView.heightAnchor.constraint(
                equalTo: view.heightAnchor, multiplier: 0.15)
        ])
    }
    private func setupCoinCollectionView() {
        self.coinCollectionView.dataSource = self
        self.coinCollectionView.delegate = self
        coinContainerView.addSubview(coinCollectionView)
        self.coinCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.coinCollectionView.leadingAnchor.constraint(
                equalTo: self.coinContainerView.leadingAnchor),
            self.coinCollectionView.trailingAnchor.constraint(
                equalTo: self.coinContainerView.trailingAnchor),
            self.coinCollectionView.topAnchor.constraint(
                equalTo: self.coinContainerView.topAnchor),
            self.coinCollectionView.bottomAnchor.constraint(
                equalTo: self.coinContainerView.bottomAnchor)
        ])
    }
    

}

