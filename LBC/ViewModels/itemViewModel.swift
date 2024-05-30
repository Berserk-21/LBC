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
    
    @Published var imageData: Data?
    
    init(product: ProductModel) {
        self.product = product
    }
    
    func loadImage() {
        
        guard let thumbUrlString = product.imagesUrl.thumb, let url = URL(string: thumbUrlString) else {
            imageData = nil
            return
        }
        
        if let cachedImageData = ImageCache.shared.image(forKey: thumbUrlString) {
            self.imageData = cachedImageData
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
            .assign(to: \.imageData, on: self)
            .store(in: &cancellables)
    }
}
