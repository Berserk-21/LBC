//
//  ProductsViewModel.swift
//  LBC
//
//  Created by Berserk on 29/05/2024.
//

import Foundation
import Combine
import UIKit

final class ProductsViewModel {
    
    // MARK: - Properties
    
    private let networkService: NetworkServiceInterface
    private let orientationService: DeviceOrientationServiceInterface
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published var products = [ProductModel]()
    @Published var error: NetworkServiceError?
    @Published var deviceOrientation: UIDeviceOrientation = .unknown
    
    // MARK: - Life Cycle
    
    init(networkService: NetworkServiceInterface = NetworkService(), orientationService: DeviceOrientationServiceInterface = DeviceOrientationService.shared) {
        self.networkService = networkService
        self.orientationService = orientationService
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
        
        orientationService.orientationPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] orientation in
                self?.deviceOrientation = orientation
            }
            .store(in: &cancellables)
    }
}
