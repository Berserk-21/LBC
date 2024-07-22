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
        return formatPrice(from: product.price)
    }
    
    var date: String {
        return formatDate(from: product.creationDate)
    }
    
    private var formattedSiret: String? {
        return formatSiret(from: product.siret)
    }
    
    var siret: String? {
        return formattedSiret
    }
    
    @Published var imageData: Data?
    var imageDataPublisher: AnyPublisher<Data?, Never> {
        return $imageData.eraseToAnyPublisher()
    }
    
    @Published var imageDataError: ImageDownloadError?
    var imageDataErrorPublisher: AnyPublisher<AlertErrorModel, Never> {
        return $imageDataError
            .compactMap({ $0 })
            .map({ self.formatError($0) })
            .eraseToAnyPublisher()
    }
    
    // MARK: - Life Cycle
    
    init(product: ProductModel, imageDownloader: ImageDownloader = ImageDownloader()) {
        self.product = product
        self.imageDownloader = imageDownloader
    }
    
    // MARK: - Fetch Data
    
    /// Use this method to reformat a date String.
    private func formatDate(from: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        guard let date = dateFormatter.date(from: product.creationDate) else {
            return product.creationDate
        }
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: date)
    }
    
    /// Use this method to format the siret String.
    private func formatSiret(from siret: String?) -> String? {
        
        guard let siret = product.siret else {
            return nil
        }
        
        return "Siret: \(String(describing: siret))"
    }
    
    /// Use this method to format price to a String.
    private func formatPrice(from price: CGFloat) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = Locale.current.currencyCode ?? "EUR"
        
        // Not selling free products here :p
        guard product.price > 0.0, let stringPrice = formatter.string(from: NSNumber(floatLiteral: product.price)) else { return Constants.HomeCollectionViewCell.invalidPriceText }
        return stringPrice
    }
    
    /// Uses this method to format an Error to a String.
    private func formatError(_ error: ImageDownloadError) -> AlertErrorModel {
        
        let title: String = "Le téléchargement de l'image a échoué."
        let errorMessage: String
        
        switch error {
        case .invalidUrl:
            errorMessage = "L'url n'est pas valide."
        case .invalidResponse:
            errorMessage = "La réponse n'est pas valide."
        case .statusCode(let statusCode):
            switch statusCode {
            case 400..<500:
                errorMessage = "La requête n'est pas autorisée."
            case 500..<600:
                errorMessage = "Le serveur a rencontré une erreur."
            default:
                errorMessage = error.localizedDescription
            }
            
        case .unknow(let error):
            errorMessage = error.localizedDescription
        }
        
        return AlertErrorModel(title: title, message: errorMessage)
    }
    
    /// Uses this method to fetch the thumbnail Image reactively.
    func loadImage() {
        
        guard let thumbUrlString = product.imagesUrl.thumb, let url = URL(string: thumbUrlString) else {
            imageData = nil
            imageDataError = ImageDownloadError.invalidUrl
            return
        }
        
        if let cachedImageData = ImageCache.shared.image(forKey: thumbUrlString) {
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
                ImageCache.shared.setImage(data, forKey: thumbUrlString)
            })
            .store(in: &cancellables)
    }
}
