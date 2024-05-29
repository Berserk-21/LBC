//
//  NetworkService.swift
//  LBC
//
//  Created by Berserk on 29/05/2024.
//

import Foundation
import Combine

enum NetworkServiceError: Error {
    
    case invalidUrl
    case invalidResponse
    case serverError
    case requestFailed(_: Error)
}

struct NetworkService {
    
    func fetchData(for urlString: String) -> AnyPublisher<Data, NetworkServiceError> {
        
        guard let url = URL(string: urlString) else {
            return Fail(error: NetworkServiceError.invalidUrl).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { result in
                guard let httpResponse = result.response as? HTTPURLResponse else {
                    throw NetworkServiceError.invalidResponse
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw NetworkServiceError.serverError
                }
                
                return result.data
            }
            .mapError{ error -> NetworkServiceError in
                if let networkServiceError = error as? NetworkServiceError {
                    return networkServiceError
                } else {
                    return NetworkServiceError.requestFailed(error)
                }
            }
            .eraseToAnyPublisher()
    }
    
}
