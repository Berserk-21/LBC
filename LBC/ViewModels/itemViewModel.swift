//
//  itemViewModel.swift
//  LBC
//
//  Created by Berserk on 29/05/2024.
//

import Foundation
import Combine

class ItemViewModel: ObservableObject {
    
    private var cancellables = Set<AnyCancellable>()
    
    let product: ProductModel
    
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = Locale.current.currencyCode ?? "EUR"
        return formatter.string(from: NSNumber(floatLiteral: product.price)) ?? "---"
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
    
    var siret: String? {
        if let siret = product.siret {
            return "Siret: \(String(describing: siret))"
        }
        return nil
    }
    
    @Published var thumbImageData: Data?
    @Published var smallImageData: Data?
    
    init(product: ProductModel) {
        self.product = product
    }
    
    /// Uses this method to fetch the thumbnail Image reactively.
    func loadThumbImage() {
        
        guard let thumbUrlString = product.imagesUrl.thumb, let url = URL(string: thumbUrlString) else {
            thumbImageData = nil
            return
        }
        
        if let cachedImageData = ImageCache.shared.image(forKey: thumbUrlString) {
            self.thumbImageData = cachedImageData
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map{ $0.data }
            .handleEvents(receiveOutput: { output in
                if let unwrappedData = output {
                    ImageCache.shared.setImage(unwrappedData, forKey: thumbUrlString)
                }
            })
            .replaceError(with: nil)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            .assign(to: \.thumbImageData, on: self)
            .store(in: &cancellables)
    }
    
    func loadSmallImage() {
        
        guard let smallUrlString = product.imagesUrl.small, let url = URL(string: smallUrlString) else {
            smallImageData = nil
            return
        }
        
        if let cachedImageData = ImageCache.shared.image(forKey: smallUrlString) {
            self.smallImageData = cachedImageData
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map{ $0.data }
            .handleEvents(receiveOutput: { output in
                if let unwrappedData = output {
                    ImageCache.shared.setImage(unwrappedData, forKey: smallUrlString)
                }
            })
            .replaceError(with: nil)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            .assign(to: \.smallImageData, on: self)
            .store(in: &cancellables)
    }
}
