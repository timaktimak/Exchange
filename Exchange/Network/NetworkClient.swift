//
//  NetworkClient.swift
//  Exchange
//
//  Created by t.galimov on 27/01/2018.
//

import Foundation

protocol NetworkClientProtocol {
    /// `completion` is executed on the default `URLSession` delegate serial queue.
    func get(_ urlString: String, completion: @escaping (Data?, Error?) -> Void)
}

class NetworkClient: NetworkClientProtocol {
    
    private let requestTimeoutInterval: TimeInterval = 10

    func get(_ urlString: String, completion: @escaping (Data?, Error?) -> Void) {
        guard let url = URL(string: urlString) else {
            assertionFailure("Could not construct a valid URL from \(urlString)")
            return
        }
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: requestTimeoutInterval)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            print(response ?? "")
            completion(data, error)
        }
        task.resume()
    }
}
