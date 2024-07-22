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
    private let imageDownloader: ImageDownloaderInterface
    private let cacheService: CacheServiceInterface
    
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
        return FormatterUtility.formatPrice(from: product.price)
    }
    
    var date: String {
        return FormatterUtility.formatDateFrom(string: product.creationDate)
    }
    
    var siret: String? {
        return FormatterUtility.formatSiret(from: product.siret)
    }
    
    @Published var imageData: Data?
    var imageDataPublisher: AnyPublisher<Data?, Never> {
        return $imageData.eraseToAnyPublisher()
    }
    
    @Published var imageDataError: NetworkServiceError?
    var imageDataErrorPublisher: AnyPublisher<AlertErrorModel, Never> {
        return $imageDataError
            .compactMap({ $0 })
            .map({ FormatterUtility.formatError($0) })
            .eraseToAnyPublisher()
    }
    
    // MARK: - Life Cycle
    
    init(product: ProductModel, imageDownloader: ImageDownloader = ImageDownloader(), cacheService: CacheServiceInterface = CacheService.shared) {
        self.product = product
        self.imageDownloader = imageDownloader
        self.cacheService = cacheService
    }
    
    // MARK: - Fetch Data
    
    /// Uses this method to fetch the thumbnail Image reactively.
    func loadImage() {
        
        guard let thumbUrlString = product.imagesUrl.thumb, let url = URL(string: thumbUrlString) else {
            imageData = nil
            imageDataError = NetworkServiceError.invalidUrl
            return
        }
        
        if let cachedImageData = cacheService.image(forKey: thumbUrlString) {
            self.imageData = cachedImageData
            return
        }
        
        imageDownloader.downloadImage(from: url)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.imageDataError = error
                    self?.imageData = nil
                }
            }, receiveValue: { [weak self] data in
                self?.imageData = data
                self?.cacheService.setImage(data, forKey: thumbUrlString)
            })
            .store(in: &cancellables)
    }
}
