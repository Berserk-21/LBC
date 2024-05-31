//
//  ProductModel.swift
//  LBC
//
//  Created by Berserk on 29/05/2024.
//

import Foundation

struct ProductModel: Decodable {
    
    let id: Int
    let categoryId: Int
    let title: String
    let description: String
    let price: Double
    let imagesUrl: ImagesUrl
    let creationDate: String
    let isUrgent: Bool
    let siret: String?
    var category: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case categoryId = "category_id"
        case title
        case description
        case price
        case imagesUrl = "images_url"
        case creationDate = "creation_date"
        case isUrgent = "is_urgent"
        case siret
        case category
    }
}

struct ImagesUrl: Decodable {
    
    let small: String?
    let thumb: String?
}
