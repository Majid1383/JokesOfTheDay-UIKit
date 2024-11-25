//
//  NetworkServices.swift
//  JokesOfTheDay-UIKit
//
//  Created by AbdulMajid Shaikh on 25/11/24.
//

import Foundation

enum NetworkError: Error
{
    case invalidURL
    case serverError
    case NetworkCrashed
    case ParsingError
    
}

final class NetworkServices
{
    
    static let shared = NetworkServices() //Singleton
    private let session : URLSession
    
    
    private init()
    {
        let config = URLSessionConfiguration.default
        self.session = URLSession(configuration: config)
    }
    
    //MARK: Generic API Request
    private func performRequest(url: URL, method: String, body: Data? = nil, completion: @escaping (Result <Data, NetworkError>) -> Void)
    {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body
        {
            request.httpBody = body
        }
        
        let task = session.dataTask(with: request)
        { data , response, error in
            
            if let error = error
            {
                completion(.failure(.NetworkCrashed))
                return
            }
            
            guard let data = data else
            {
                completion(.failure(.ParsingError))
                return
            }
            
            completion(.success(data))
        }
        task.resume()
    }
    
    
    
    //MARK: GET Request
    func get(urlString: String, completion: @escaping (Result< Data, NetworkError >) -> Void)
    {
        guard let url = URL(string: urlString) else
        {
            completion(.failure(.invalidURL))
            return
        }
        performRequest(url: url, method: "GET", completion: completion)
    }
   
    
}
