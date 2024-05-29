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
