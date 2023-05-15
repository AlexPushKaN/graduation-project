//
//  Network.swift
//  GraduationProject
//
//  Created by Александр Муклинов on 05.05.2023.
//

import Foundation

class NetworkManager {
    func performData(url:URL, completionHandler: @escaping (Currencies) -> Void) {
        let request = URLRequest(url: url)
        let session = URLSession.shared
        session.dataTask(with: request) { data, response, error in
            if error != nil {
                print(String(describing: error?.localizedDescription))
            } else {
                guard let response = response as? HTTPURLResponse else { return }
                if response.statusCode/100 == 2 {
                    let decoder = JSONDecoder()
                    guard let data = data else { return }
                    let currencies = try? decoder.decode(Currencies.self, from: data)
                    completionHandler(currencies ?? Currencies(date: "", usd: [:]) )
                }
            }
        }.resume()
    }
}
