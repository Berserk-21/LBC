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
    @Published var error: NetworkServiceError?
    
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
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                switch result {
                case .finished:
                    break
                case .failure(let error):
                    self?.error = error
                }
            } receiveValue: { [weak self] products in
                self?.products = products
            }
            .store(in: &cancellables)
    }
}
