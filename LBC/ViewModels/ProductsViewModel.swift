//
//  ProductsViewModel.swift
//  LBC
//
//  Created by Berserk on 29/05/2024.
//

import Foundation
import Combine

final class ProductsViewModel {
    
    // MARK: - Properties
    
    private let networkService: NetworkServiceInterface
    private var cancellables = Set<AnyCancellable>()
    
    @Published var products = [ProductModel]()
    
    weak var collectionView: ProductCollectionViewInterface?
    weak var productsViewControllerDelegate: ProductsViewControllerInterface?
    
    // MARK: - Life Cycle
    
    init(networkService: NetworkServiceInterface = NetworkService()) {
        self.networkService = networkService
    }
    
    // MARK: - Business Logic
    
    func start() {
        
        fetchData()
    }
    
    /// Use this method to fetch data and present the result in views.
    private func fetchData() {
        
        networkService.fetchData()
            .sink { [weak self] result in
                switch result {
                case .finished:
                    break
                case .failure(let error):
                    DispatchQueue.main.async {
                        self?.presentAlert(error)
                    }
                }
            } receiveValue: { [weak self] products in
                
                DispatchQueue.main.async {
                    self?.products = products
                    self?.updateData()
                }
            }
            .store(in: &cancellables)
    }
    
    // Could create a protocol to communicate with the viewController and present errors.
    private func presentAlert(_ error: NetworkServiceError) {
        
        productsViewControllerDelegate?.presentAlert(with: error)
    }
    
    private func updateData() {
        
        collectionView?.updateData()
    }
}
