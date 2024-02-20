//
//  NetworkManager.swift
//  CryptoMonitorMVVM
//
//  Created by Emir Nasyrov on 30.10.2023.
//

import Foundation

protocol NetworkManagerProtocol {
    func fetchCoins(response: @escaping([Datum]?, NetworkError?)-> Void)
    func fetchTickerDetails(withID id: String, completion: @escaping (Result<Data, Error>) -> Void)
}

struct NetworkManager: NetworkManagerProtocol {
    // MARK: - Variables
    let baseURL = "https://api.coinlore.net/api/"
    
    func fetchCoins(response: @escaping([Datum]?, NetworkError?)-> Void) {
        fetchTickers {  result in
            switch result {
            case .success(let data):
                do {
                    let allCoins = try JSONDecoder().decode(AllCoins.self, from: data)
                    response(allCoins.data, nil)
                } catch {
                    print("Ошибка при декодировании данных: \(error)")
                }
            case .failure(let error):
                print("Ошибка при декодировании данных: \(error)")
            }
        }
    }
    
    private func fetchTickers(completion: @escaping (Result<Data, Error>) -> Void) {
        let tickersURL = baseURL + "tickers/"
        fetchDetail(from: tickersURL, completion: completion)
    }
    
    func fetchTickerDetails(withID id: String, completion: @escaping (Result<Data, Error>) -> Void) {
        let detailsURL = baseURL + "ticker/?id=\(id)"
        fetchDetail(from: detailsURL, completion: completion)
    }
    
    private func fetchDetail(from urlString: String, completion: @escaping (Result<Data, Error>) -> Void) { guard let url = URL(string: urlString) else {
        completion(.failure(NetworkError.invalidURL))
        return
    }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                completion(.success(data))
            }
        }.resume()
    }
}

enum NetworkError: Error {
    case invalidURL
}
