//
//  ImageCache.swift
//  LBC
//
//  Created by Berserk on 30/05/2024.
//

import UIKit

class ImageCache {
    
    static let shared = ImageCache()
    
    private init() {}
    
    private var cache = NSCache<NSString, NSData>()
    
    func image(forKey key: String) -> Data? {
        return cache.object(forKey: NSString(string: key)) as? Data
    }
    
    func setImage(_ imageData: Data, forKey key: String) {
        cache.setObject(NSData(data: imageData), forKey: NSString(string: key))
    }
}
