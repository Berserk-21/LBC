//
//  ImageDownloader.swift
//  LBC
//
//  Created by Berserk on 18/07/2024.
//

import Foundation
import Combine

enum ImageDownloadError: Error {
    case invalidResponse
    case statusCode(Int)
    case unknow(Error)
}

final class ImageDownloader {
    
    // MARK: - Properties
    
    private let session: URLSession
    
    // MARK: - Initialization
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    // MARK: - Core Methods
    
    /// Use this method to download image data from a URL.
    func downloadImage(from url: URL) -> AnyPublisher<Data, ImageDownloadError> {

        return session.dataTaskPublisher(for: url)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                
                guard httpResponse.statusCode == 200 else {
                    throw ImageDownloadError.statusCode(httpResponse.statusCode)
                }

                return data
            }
            .mapError({ error -> ImageDownloadError in
                if let imageDownloadError = error as? ImageDownloadError {
                    return imageDownloadError
                } else {
                    return .unknow(error)
                }
            })
            .eraseToAnyPublisher()
    }
}
