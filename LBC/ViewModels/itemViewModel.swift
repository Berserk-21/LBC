//
//  itemViewModel.swift
//  LBC
//
//  Created by Berserk on 29/05/2024.
//

import Foundation
import Combine

class ItemViewModel: ObservableObject {
    
    @Published var imageData: Data?
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
    
    init(product: ProductModel) {
        self.product = product
    }
    
    func loadImage() {
        
        guard let thumbUrlString = product.imagesUrl.thumb, let url = URL(string: thumbUrlString) else {
            imageData = nil
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map{ $0.data }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .assign(to: \.imageData, on: self)
            .store(in: &cancellables)
        }
}
