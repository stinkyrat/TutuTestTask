//
//  APIService.swift
//  TutuTestTask
//
//  Created by Phlegma on 17.12.2021.
//

import Foundation

class APIService: NSObject {
    
    let url = "https://jsonplaceholder.typicode.com/users"
    
    enum Result <T>{
        case Success(T)
        case Error(String)
    }
    
    func getDataWith(completion: @escaping (Result<[[String: AnyObject]]>) -> Void) {
        guard let url = URL(string: url) else {
            return completion(.Error("Invalid URL"))
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                return completion(.Error(error!.localizedDescription))
            }
            guard let data = data else {
                return completion(.Error(error?.localizedDescription ?? "Nothing to show: empty response"))
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: [.mutableContainers]) as? [[String: AnyObject]] {
                    DispatchQueue.main.async {
                        completion(.Success(json))
                    }
                } else {
                    return completion(.Error("Unable to parse the response"))
                }
            } catch let error {
                return completion(.Error(error.localizedDescription))
            }
        }.resume()
    }
    
}

