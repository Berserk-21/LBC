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
    case decodingFailed(_: Error)
}

protocol NetworkServiceInterface {
    func fetchData() -> AnyPublisher<[ProductModel], NetworkServiceError>
}

struct NetworkService: NetworkServiceInterface {
    
    func fetch(for urlString: String) -> AnyPublisher<Data, NetworkServiceError> {
        
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
    
    func fetchData() -> AnyPublisher<[ProductModel], NetworkServiceError> {
        
        let categories = fetch(for: Constants.NetworkService.categoriesUrl)
            .decode(type: [CategoryModel].self, decoder: JSONDecoder())
            .mapError { error -> NetworkServiceError in
                return NetworkServiceError.decodingFailed(error)
            }
            .eraseToAnyPublisher()
        
        let products = fetch(for: Constants.NetworkService.productsUrl)
            .decode(type: [ProductModel].self, decoder: JSONDecoder())
            .mapError { error -> NetworkServiceError in
                return NetworkServiceError.decodingFailed(error)
            }
            .eraseToAnyPublisher()
        
        return Publishers.Zip(categories, products)
            .map { categories, products -> [ProductModel] in
                
                let categoriesDict = Dictionary(uniqueKeysWithValues: categories.map({ ($0.id, $0.name) }))

                let completedProducts = products.map { product in
                    var completedProduct = product
                    completedProduct.category = categoriesDict[product.categoryId]
                    return completedProduct
                }
                
                return completedProducts
            }
            .eraseToAnyPublisher()
    }
    
}
