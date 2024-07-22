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
    case requestFailed
    case decodingFailed
    case unknown(_: Error)
    case statusCode(_: Int)
}

protocol NetworkServiceInterface {
    func fetchData() -> AnyPublisher<[ProductModel], NetworkServiceError>
}

struct NetworkService: NetworkServiceInterface {
    
    /**
     Use this method to fetch data from an url.
     - parameter urlString: the url of type String, used in the request.
     - Returns a Publisher that we can subscribe to, to receive the result.
     */
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
                    throw NetworkServiceError.statusCode(httpResponse.statusCode)
                }
                
                return result.data
            }
            .mapError{ error -> NetworkServiceError in
                if let networkServiceError = error as? NetworkServiceError {
                    return networkServiceError
                } else {
                    return NetworkServiceError.requestFailed
                }
            }
            .eraseToAnyPublisher()
    }
    
    /**
     Use this method to fetch products datas completed with their corresponding categories.
     - Returns a Publisher that we can subscribe to, to receive the result.
     */
    func fetchData() -> AnyPublisher<[ProductModel], NetworkServiceError> {
        
        let categories = fetch(for: Constants.NetworkService.categoriesUrl)
            .decode(type: [CategoryModel].self, decoder: JSONDecoder())
            .mapError { error -> NetworkServiceError in
                return NetworkServiceError.decodingFailed
            }
            .eraseToAnyPublisher()
            
        let products = fetch(for: Constants.NetworkService.productsUrl)
            .decode(type: [ProductModel].self, decoder: JSONDecoder())
            .mapError { error -> NetworkServiceError in
                return NetworkServiceError.decodingFailed
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
