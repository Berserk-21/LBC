//
//  ImageDownloader.swift
//  LBC
//
//  Created by Berserk on 18/07/2024.
//

import Foundation
import Combine

protocol FetchImageInterface {
    func fetchImage(from urlString: String) -> AnyPublisher<Data, NetworkServiceError>
}

final class FetchImageService: FetchImageInterface {
    
    // MARK: - Properties
    
    private let session: URLSession
    private let cacheService: CacheServiceInterface
    
    // MARK: - Initialization
    
    init(session: URLSession = URLSession.shared, cacheService: CacheServiceInterface = CacheService.shared) {
        self.session = session
        self.cacheService = cacheService
    }
    
    // MARK: - Core Methods
    
    /// Use this method to fetch image data from a url String.
    func fetchImage(from urlString: String) -> AnyPublisher<Data, NetworkServiceError> {
        
        if let cachedData = cacheService.image(forKey: urlString) {
            return Just(cachedData)
                .setFailureType(to: NetworkServiceError.self)
                .eraseToAnyPublisher()
        }
        
        guard let url = URL(string: urlString) else {
            return Fail(error: NetworkServiceError.invalidUrl)
                .eraseToAnyPublisher()
        }

        return session.dataTaskPublisher(for: url)
            .tryMap { [weak self] data, response in
                
                guard let self = self else { throw NetworkServiceError.cancelled }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                
                guard httpResponse.statusCode == 200 else {
                    throw NetworkServiceError.statusCode(httpResponse.statusCode)
                }
                
                self.cacheService.setImage(data, forKey: urlString)
                
                return data
            }
            .mapError({ error -> NetworkServiceError in
                if let networkServiceError = error as? NetworkServiceError {
                    return networkServiceError
                } else {
                    return .unknown(error)
                }
            })
            .eraseToAnyPublisher()
    }
}
