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
    var products: [ProductModel] { get }
    var didFetchDataPublisher: AnyPublisher<[ProductModel], Never> { get }
    var didFetchDataWithErrorPublisher: AnyPublisher<AlertErrorModel, Never> { get }
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
    var didFetchDataWithErrorPublisher: AnyPublisher<AlertErrorModel, Never> {
        $error
            .compactMap({ $0 })
            .map({ self.formatError($0) })
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
    
    private func formatError(_ error: NetworkServiceError) -> AlertErrorModel {
        
        let title: String = "Le téléchargement de l'image a échoué."
        let errorMessage: String
        
        // Improvements
        // send error localized message to private analytics domain.
        // error.localizedDescription
        // Use localizable strings.
        
        switch error {
        case .invalidUrl:
            errorMessage = "L'url n'est pas valide."
        case .invalidResponse:
            errorMessage = "La réponse n'est pas valide."
        case .decodingFailed:
            errorMessage = "Le décodage des données a échoué"
        case .requestFailed:
            errorMessage = "La requête a échoué."
        case .serverError:
            errorMessage = "Le serveur a rencontré une erreur."
        }
        
        return AlertErrorModel(title: title, message: errorMessage)
    }
}
