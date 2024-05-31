//
//  Constants.swift
//  LBC
//
//  Created by Berserk on 29/05/2024.
//

import Foundation

struct Constants {
    struct NetworkService {
        static let productsUrl = "https://raw.githubusercontent.com/leboncoin/paperclip/master/listing.json"
        static let categoriesUrl = "https://raw.githubusercontent.com/leboncoin/paperclip/master/categories.json"
    }
    
    struct HomeCollectionViewCell {
        static let stackViewSpacing = 4.0
        static let imageRatio = 1.0
        static let invalidPriceText = "Prix inconnu"
    }
    
    struct ProductViewController {
        
        struct Navigation {
            static let title = "Leboncoin"
        }
        struct Alert {
            static let okTitle = "OK"
            static let errorTitle = "Impossible de charger les produits"
            static let errorMessage = "Vérifiez votre connexion et réessayez !"
        }
    }
    
    struct ProductDetailViewController {
        static let buyButtonTitle = "ACHETER"
        static let isUrgentText = "URGENT"
        static let comingSoon = "coming soon.."
    }
}
