//
//  ProductDetailViewModel.swift
//  LBC
//
//  Created by Berserk on 29/05/2024.
//

import Foundation
import Combine

protocol ProductDetailViewModelInterface {
    var title: String { get }
    var category: String? { get }
    var description: String { get }
    var date: String { get }
    var price: String { get }
    var isUrgent: Bool { get }
    var siret: String? { get }
    var imageDataPublisher: AnyPublisher<Data?, Never> { get }
    var imageDataErrorPublisher: AnyPublisher<AlertErrorModel, Never> { get }
    
    func loadImage()
}

final class ProductDetailViewModel: ProductDetailViewModelInterface {
    
    // MARK: - Properties
    
    private var cancellables = Set<AnyCancellable>()
    
    private let product: ProductModel
    private let fetchImageService: FetchImageServiceInterface
    
    var title: String {
        return product.title
    }
    
    var category: String? {
        return product.category
    }
    
    var isUrgent: Bool {
        return product.isUrgent
    }
    
    var description: String {
        return product.description
    }
    
    var price: String {
        return FormatterUtility.shared.formatPrice(from: product.price)
    }
    
    var date: String {
        return FormatterUtility.shared.formatDateFrom(string: product.creationDate)
    }
    
    var siret: String? {
        return FormatterUtility.shared.formatSiret(from: product.siret)
    }
    
    var imageUrlString: String? {
        return product.imagesUrl.thumb
    }
    
    @Published var imageData: Data?
    var imageDataPublisher: AnyPublisher<Data?, Never> {
        return $imageData.eraseToAnyPublisher()
    }
    
    @Published var imageDataError: NetworkServiceError?
    var imageDataErrorPublisher: AnyPublisher<AlertErrorModel, Never> {
        return $imageDataError
            .compactMap({ $0 })
            .map({ FormatterUtility.shared.formatError($0) })
            .eraseToAnyPublisher()
    }
    
    // MARK: - Life Cycle
    
    init(product: ProductModel, imageDownloader: FetchImageServiceInterface = FetchImageService()) {
        self.product = product
        self.fetchImageService = imageDownloader
    }
    
    // MARK: - Fetch Data
    
    /// Uses this method to fetch the thumbnail Image reactively.
    func loadImage() {
        
        guard let thumbUrlString = imageUrlString else {
            imageData = nil
            print("This product does not have a thumb image.")
            return
        }
        
        fetchImageService.fetchImage(from: thumbUrlString)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.imageDataError = error
                    self?.imageData = nil
                }
            }, receiveValue: { [weak self] data in
                self?.imageData = data
            })
            .store(in: &cancellables)
    }
}
