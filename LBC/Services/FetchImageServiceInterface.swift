//
//  ImageDownloader.swift
//  LBC
//
//  Created by Berserk on 18/07/2024.
//

import Foundation
import Combine

protocol FetchImageServiceInterface {
    func fetchImage(from urlString: String) -> AnyPublisher<Data, NetworkServiceError>
}

final class FetchImageService: FetchImageServiceInterface {
    
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
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    if (400...499).contains(httpResponse.statusCode) {
                        throw NetworkServiceError.unauthorized
                    } else if (500...599).contains(httpResponse.statusCode) {
                        throw NetworkServiceError.serverFailed
                    } else {
                        throw NetworkServiceError.unknown
                    }
                }
                
                self.cacheService.setImage(data, forKey: urlString)
                
                return data
            }
            .mapError({ error -> NetworkServiceError in
                return error as? NetworkServiceError ?? .unknown
            })
            .eraseToAnyPublisher()
    }
}
