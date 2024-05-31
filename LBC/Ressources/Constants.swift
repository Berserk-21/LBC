//
//  Constants.swift
//  LBC
//
//  Created by Berserk on 29/05/2024.
//

import Foundation
import UIKit

struct Constants {
    struct NetworkService {
        static let productsUrl = "https://raw.githubusercontent.com/leboncoin/paperclip/master/listing.json"
        static let categoriesUrl = "https://raw.githubusercontent.com/leboncoin/paperclip/master/categories.json"
    }
    
    struct HomeCollectionViewCell {
        static let titleLabelFont = UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight.medium)
        static let priceLabelFont = UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight.heavy)
        static let descriptionLabelFont = UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.medium)
        static let categoryLabelFont = UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.regular)
        static let creationDateLabelFont = UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.light)
        static let isUrgentLabelFont = UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.medium)
        static let siretLabelFont = UIFont.systemFont(ofSize: 12.0, weight: UIFont.Weight.light)
        static let stackViewSpacing = 4.0
        static let imageRatio = 1.0
        static let invalidPriceText = "Prix inconnu"
    }
}
