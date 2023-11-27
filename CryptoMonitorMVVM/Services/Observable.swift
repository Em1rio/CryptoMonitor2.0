//
//  Observable.swift
//  CryptoMonitorMVVM
//
//  Created by Emir Nasyrov on 20.10.2023.
//

import Foundation

final class Observable<T> {
    var value: T? {
        didSet {
            listener?(value)
        }
    }
    init(_ value: T?) {
        self.value = value
    }
    
    private var listener: ((T?) -> Void)?
    
    func bind(_ listener: @escaping (T?) -> Void) {
        listener(value)
        self.listener = listener
    }
}
