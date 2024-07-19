//
//  ProductsViewModel.swift
//  LBC
//
//  Created by Berserk on 29/05/2024.
//

import Foundation
import Combine
import UIKit

protocol ProductsViewModelInterface {
    // Inputs
    func viewWillLayoutSubviews()
    func fetchData()
    
    // Outputs
    var didFetchDataPublisher: AnyPublisher<[ProductModel], Never> { get }
    var products: [ProductModel] { get }
    var didFetchDataWithErrorPublisher: AnyPublisher<NetworkServiceError, Never> { get }
    var viewWillLayoutSubviewsPublisher: AnyPublisher<Void, Never> { get }
}

final class ProductsViewModel: ProductsViewModelInterface {
    
    // MARK: - Properties
    
    private let networkService: NetworkServiceInterface
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published var products = [ProductModel]()
    var didFetchDataPublisher: AnyPublisher<[ProductModel], Never> {
        $products.eraseToAnyPublisher()
    }
    
    @Published private var error: NetworkServiceError?
    var didFetchDataWithErrorPublisher: AnyPublisher<NetworkServiceError, Never> {
        $error
            .compactMap({ $0 })
            .eraseToAnyPublisher()
    }
    
    var viewWillLayoutSubviewsSubject = PassthroughSubject<Void, Never>()
    var viewWillLayoutSubviewsPublisher: AnyPublisher<Void, Never> {
        return viewWillLayoutSubviewsSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Life Cycle
    
    init(networkService: NetworkServiceInterface = NetworkService()) {
        self.networkService = networkService
    }
    
    // MARK: - Business Logic
    
    /// Use this method to fetch data and present the result in views.
    func fetchData() {
        
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
    
    func viewWillLayoutSubviews() {
        // Do any work to filter changes.
        viewWillLayoutSubviewsSubject.send()
    }
}
