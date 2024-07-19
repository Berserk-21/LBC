//
//  ProductDetailViewModel.swift
//  LBC
//
//  Created by Berserk on 29/05/2024.
//

import Foundation
import Combine

final class ProductDetailViewModel {
    
    // MARK: - Properties
    
    private var cancellables = Set<AnyCancellable>()
    
    private let product: ProductModel
    private let imageDownloader: ImageDownloader
    private let urlSession: URLSession
    
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = Locale.current.currencyCode ?? "EUR"
        
        // Not selling free products here :p
        guard product.price > 0.0, let stringPrice = formatter.string(from: NSNumber(floatLiteral: product.price)) else { return Constants.HomeCollectionViewCell.invalidPriceText }
        return stringPrice
    }
    
    var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        guard let date = dateFormatter.date(from: product.creationDate) else {
            return product.creationDate
        }
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: date)
    }
    
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
    
    var formattedSiret: String? {
        if let siret = product.siret {
            return "Siret: \(String(describing: siret))"
        }
        return nil
    }
    
    var thumbImageUrlString: String? {
        return product.imagesUrl.thumb
    }
    
    @Published var imageData: Data?
    
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
        
        guard let thumbUrlString = thumbImageUrlString, let url = URL(string: thumbUrlString) else {
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
        
//        URLSession.shared.dataTaskPublisher(for: url)
//            .map{ $0.data }
//            .handleEvents(receiveOutput: { output in
//                if let unwrappedData = output {
//                    ImageCache.shared.setImage(unwrappedData, forKey: thumbUrlString)
//                }
//            })
//            .replaceError(with: nil)
//            .subscribe(on: DispatchQueue.global(qos: .background))
//            .receive(on: DispatchQueue.main)
//            .assign(to: \.imageData, on: self)
//            .store(in: &cancellables)
    }
}
