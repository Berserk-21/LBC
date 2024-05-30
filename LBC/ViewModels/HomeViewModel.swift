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
    
    let networkService: NetworkServiceInterface
    var cancellables = Set<AnyCancellable>()
    
    @Published var products = [ProductModel]()
    
    weak var collectionView: HomeCollectionViewInterface?
    
    // MARK: - Life Cycle
    
    init(networkService: NetworkServiceInterface = NetworkService()) {
        self.networkService = networkService
    }
    
    // MARK: - Business Logic
    
    func start() {
        
        fetchData()
    }
    
    private func fetchData() {
        
        networkService.fetchData()
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
