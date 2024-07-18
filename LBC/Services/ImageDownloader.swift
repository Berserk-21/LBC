//
//  ImageDownloader.swift
//  LBC
//
//  Created by Berserk on 18/07/2024.
//

import Foundation
import Combine

final class ImageDownloader {
    
    // MARK: - Properties
    
    private let session: URLSession
    
    // MARK: - Initialization
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    // MARK: - Core Methods
    
    /// Use this method to download image data from a URL.
    func downloadImage(from url: URL) -> AnyPublisher<Data, Error> {

        return session.dataTaskPublisher(for: url)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }

                return data
            }
            .eraseToAnyPublisher()
    }
}
