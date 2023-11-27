//
//  MainViewController + CollectionView.swift
//  CryptoMonitorMVVM
//
//  Created by Emir Nasyrov on 20.10.2023.
//

import UIKit
import RealmSwift

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == numPadCollectionView {
            return self.viewModel.numPadButtonCells.count
        }else {
            return self.viewModel.quickAccessCoinsCells.count + 1
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.numPadCollectionView {
            guard let numCell = collectionView.dequeueReusableCell(withReuseIdentifier: NumberPadCell.identifire, for: indexPath) as? NumberPadCell else {
                fatalError("Error")
            }
            let numPadButtons = self.viewModel.numPadButtonCells[indexPath.row]
            numCell.configure(with: numPadButtons)
            return numCell
        }  else if collectionView == self.coinCollectionView {
            // Обработка ячеек coinCollectionView
            if indexPath.row == 0 {
                guard let showAllButtonCell = collectionView.dequeueReusableCell(withReuseIdentifier: ShowAllButtonCell.identifire, for: indexPath) as? ShowAllButtonCell else {
                    fatalError("Error")
                }
                showAllButtonCell.configure()
                return showAllButtonCell
            } else {
                guard let quickAccessCell = collectionView.dequeueReusableCell(withReuseIdentifier: CoinButtonCell.identifire, for: indexPath) as? CoinButtonCell else {
                    fatalError("Error")
                }
                let quickAccessButtons = self.viewModel.quickAccessCoinsCells[indexPath.row - 1]
                quickAccessCell.configure(with: quickAccessButtons)
                return quickAccessCell
            }
        } else {
            fatalError("Unknown collectionView")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      
        return CGSize(width: (numPadContainerSize.width/3)-2, height: (numPadContainerSize.height/4)-2)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == numPadCollectionView {
            // Обработка выбора элемента в numPadCollectionView
            let selectedSegmentIndex = LabelSelection.selectedSegmentIndex
            let buttonCell = self.viewModel.numPadButtonCells[indexPath.row]
            var observableToUpdate: Observable<String>
            
            if selectedSegmentIndex == 0 {
                observableToUpdate = quantityLabelObservable
            } else {
                observableToUpdate = priceLabelObservable
                
            }
            // Обработка нажатия кнопки сброса
            if case .allClear = buttonCell {
                   self.viewModel.accumulatedValue = 0.0
                   self.viewModel.canAddDecimal = true
                   self.viewModel.isFirstInteractionWithNumPad = true
                   observableToUpdate.value = "0.0"
            } else {
                if observableToUpdate.value?.count ?? 0 < 10 {
            // Обработка нажатия кнопки дроби
                    if case .decimal = buttonCell {
                        if self.viewModel.canAddDecimal && !(observableToUpdate.value?.contains(".") ?? false) {
                                if let currentValue = observableToUpdate.value {
                                    observableToUpdate.value = currentValue + "."
                                }
                            }

                    }
            // Обработка нажатия номерных кнопок
            //MARK: - TODO: Устранить возможность ввода 0123
                    else if case .number(let number) = buttonCell {
                        if self.viewModel.isFirstInteractionWithNumPad && observableToUpdate.value == "0.0" {
                            observableToUpdate.value = "\(number)"
                            self.viewModel.isFirstInteractionWithNumPad = false
                        } else {
                            if observableToUpdate.value == "0" && number == 0 {
                                observableToUpdate.value = "0.0"
                            } else {
                                observableToUpdate.value = (observableToUpdate.value ?? "") + "\(number)"
                            }
                        }
                    }
                }
            }

        } else if collectionView == coinCollectionView {
            // Обработка выбора элемента в coinCollectionView
            if indexPath.row == 0 {
                coordinator?.coordinateToAllCoins { [weak self] AllCoinsCellModel in
                    guard let quantity = self?.quantityLabelObservable.value,
                          let price = self?.priceLabelObservable.value else {
                            print("Somethings goes wrong")
                        return
                    }
                    self?.viewModel.saveToDataBase(AllCoinsCellModel, isPurchase: self?.isPurchase ?? true, quantity: Decimal128(value: quantity), price: Decimal128(value: price))
                    self?.LabelSelection.selectedSegmentIndex = 0
                    self?.labelSelectionValueChanged()
                    self?.quantityLabelObservable.value = "0.0"
                    self?.priceLabelObservable.value = "0.0"
                }
            } else {
                let buttonCell = self.viewModel.quickAccessCoinsCells[indexPath.row - 1]
                self.viewModel.saveToDataBase(buttonCell, isPurchase: self.isPurchase, quantity: Decimal128(value: quantityLabelObservable.value ?? 0.0), price: Decimal128(value: priceLabelObservable.value ?? 0.0))
                self.LabelSelection.selectedSegmentIndex = 0
                self.labelSelectionValueChanged()
                self.quantityLabelObservable.value = "0.0"
                self.priceLabelObservable.value = "0.0"
                
            }
        }
    }
 
    // TO DO: Обнуление после записи в базу 
}
