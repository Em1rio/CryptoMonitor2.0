//
//  DetailViewModel.swift
//  CryptoMonitorMVVM
//
//  Created by Emir Nasyrov on 18.10.2023.
//

import Foundation

final class DetailViewModel {
    //TODO:
    //ЗАпрос маркет прайса
    //Высчитать среднюю
   // Настроить таблицу  в которой будут все покупки по выбранному id или имени
    //Высота ячейки 60
    //Удаление транзацкии и переасчет стоимости актива
    // Форматировать дату для использования ее в качестве секции в транзакциях
    
    // MARK: - Variables
    private let networkManager: NetworkManagerProtocol
    private let dataBaseManager: DBManagerProtocol
    // MARK: - Lifecycle
    init(_ networkManager: NetworkManagerProtocol,
         _ dataBaseManager: DBManagerProtocol) {
        self.networkManager = networkManager
        self.dataBaseManager = dataBaseManager
    }
    
}
