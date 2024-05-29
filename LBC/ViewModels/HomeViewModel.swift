//
//  HomeViewModel.swift
//  LBC
//
//  Created by Berserk on 29/05/2024.
//

import Foundation
import Combine

final class HomeViewModel {
    
    // MARK: - Properties
    
    let networkService: NetworkService
    var cancellables = Set<AnyCancellable>()
    
    var products = [ProductModel]()
    
    weak var collectionView: HomeCollectionViewInterface?
    
    // MARK: - Life Cycle
    
    init(networkService: NetworkService = NetworkService()) {
        self.networkService = networkService
        
        fetchData()
    }
    
    // MARK: - Business Logic
    
    private func fetchData() {
        
        let categoriesPublisher = networkService.fetchData(for: Constants.NetworkService.categoriesUrl)
            .decode(type: [CategoryModel].self, decoder: JSONDecoder())
            .mapError { error -> NetworkServiceError in
                return NetworkServiceError.decodingFailed(error)
            }
            .eraseToAnyPublisher()
        
        let productsPublisher = networkService.fetchData(for: Constants.NetworkService.productsUrl)
            .decode(type: [ProductModel].self, decoder: JSONDecoder())
            .mapError { error -> NetworkServiceError in
                print(error)
                return NetworkServiceError.decodingFailed(error)
            }
            .eraseToAnyPublisher()
        
        Publishers.Zip(categoriesPublisher, productsPublisher)
            .map { categories, products -> [ProductModel] in
                
                let categoriesDict = Dictionary(uniqueKeysWithValues: categories.map({ ($0.id, $0.name) }))
//
                let completedProducts = products.map { product in
                    var completedProduct = product
                    completedProduct.category = categoriesDict[product.categoryId]
                    return completedProduct
                }
                
                return completedProducts
            }
            .sink { [weak self] result in
                switch result {
                case .finished:
                    break
                case .failure(let error):
                    self?.presentAlert(error)
                }
            } receiveValue: { [weak self] products in
                
                DispatchQueue.main.async {
                    self?.products = products
                    self?.updateData()
                }
            }
            .store(in: &cancellables)
    }
    
    private func presentAlert(_ error: NetworkServiceError) {
        
    }
    
    private func updateData() {
        
        
        collectionView?.updateData()
    }
}
