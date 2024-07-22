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
    
    func loadImage()
}

final class ProductDetailViewModel: ProductDetailViewModelInterface {
    
    // MARK: - Properties
    
    private var cancellables = Set<AnyCancellable>()
    
    private let product: ProductModel
    private let imageDownloader: ImageDownloader
    private let urlSession: URLSession
    
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
    
    private var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = Locale.current.currencyCode ?? "EUR"
        
        // Not selling free products here :p
        guard product.price > 0.0, let stringPrice = formatter.string(from: NSNumber(floatLiteral: product.price)) else { return Constants.HomeCollectionViewCell.invalidPriceText }
        return stringPrice
    }
    
    var price: String {
        return formattedPrice
    }
    
    private var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        guard let date = dateFormatter.date(from: product.creationDate) else {
            return product.creationDate
        }
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: date)
    }
    
    var date: String {
        return formattedDate
    }
    
    private var formattedSiret: String? {
        if let siret = product.siret {
            return "Siret: \(String(describing: siret))"
        }
        return nil
    }
    
    var siret: String? {
        return formattedSiret
    }
    
    @Published var imageData: Data?
    var imageDataPublisher: AnyPublisher<Data?, Never> {
        return $imageData.eraseToAnyPublisher()
    }
    
    // Not using it because the quality is surprisingly worst than the thumbnail.
//    @Published var smallImageData: Data?
    
    // MARK: - Life Cycle
    
    init(product: ProductModel, urlSession: URLSession = URLSession.shared, imageDownloader: ImageDownloader = ImageDownloader()) {
        self.product = product
        self.urlSession = urlSession
        self.imageDownloader = imageDownloader
    }
    
    // MARK: - Fetch Data
    
    /// Uses this method to fetch the thumbnail Image reactively.
    func loadImage() {
        
        guard let thumbUrlString = product.imagesUrl.thumb, let url = URL(string: thumbUrlString) else {
            imageData = nil
            return
        }
        
        if let cachedImageData = ImageCache.shared.image(forKey: thumbUrlString) {
            self.imageData = cachedImageData
            return
        }
        
        imageDownloader.downloadImage(from: url)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Failed to download image for \(url): ",error)
                }
            }, receiveValue: { [weak self] data in
                self?.imageData = data
                ImageCache.shared.setImage(data, forKey: thumbUrlString)
            })
            .store(in: &cancellables)
    }
}
