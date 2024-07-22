//
//  ImageDownloader.swift
//  LBC
//
//  Created by Berserk on 18/07/2024.
//

import Foundation
import Combine

protocol ImageDownloaderInterface {
    func downloadImage(from url: URL) -> AnyPublisher<Data, NetworkServiceError>
}

final class ImageDownloader: ImageDownloaderInterface {
    
    // MARK: - Properties
    
    private let session: URLSession
    
    // MARK: - Initialization
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    // MARK: - Core Methods
    
    /// Use this method to download image data from a URL.
    func downloadImage(from url: URL) -> AnyPublisher<Data, NetworkServiceError> {

        return session.dataTaskPublisher(for: url)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                
                guard httpResponse.statusCode == 200 else {
                    throw NetworkServiceError.statusCode(httpResponse.statusCode)
                }

                return data
            }
            .mapError({ error -> NetworkServiceError in
                if let imageDownloadError = error as? NetworkServiceError {
                    return imageDownloadError
                } else {
                    return .unknown(error)
                }
            })
            .eraseToAnyPublisher()
    }
}
