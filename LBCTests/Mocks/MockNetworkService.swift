//
//  MockNetworkService.swift
//  LBCTests
//
//  Created by Berserk on 29/05/2024.
//

import Foundation
import Combine
@testable import LBC

class MockNetworkService: NetworkServiceInterface {
    
    var categoriesPublisher: AnyPublisher<Data, NetworkServiceError>!
    var productsPublisher: AnyPublisher<Data, NetworkServiceError>!
    
    func fetchData() -> AnyPublisher<[ProductModel], NetworkServiceError> {
        
        let categories = categoriesPublisher
            .decode(type: [CategoryModel].self, decoder: JSONDecoder())
            .mapError { error -> NetworkServiceError in
                return NetworkServiceError.decodingFailed(error)
            }
            .eraseToAnyPublisher()
        
        let products = productsPublisher
            .decode(type: [ProductModel].self, decoder: JSONDecoder())
            .mapError { error -> NetworkServiceError in
                print(error)
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
