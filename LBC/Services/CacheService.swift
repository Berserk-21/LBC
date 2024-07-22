//
//  ImageCache.swift
//  LBC
//
//  Created by Berserk on 30/05/2024.
//

import UIKit

protocol CacheServiceInterface {
    func image(forKey key: String) -> Data?
    func setImage(_ data: Data, forKey key: String)
}

final class CacheService: CacheServiceInterface {
    
    static let shared = CacheService()
    
    private init() {}
    
    private var cache = NSCache<NSString, NSData>()
    
    /**
     Use this method to fetch an image data from cache.
     - parameter key: A unique String
     - returns: The Data stored in the cache with the key, can be nil.
     */
    ///
    func image(forKey key: String) -> Data? {
        return cache.object(forKey: NSString(string: key)) as? Data
    }
    
    /**
     Use this method to cache ImageData.
     - parameter imageData: The Data we want to store.
     - parameter key: A unique String.
     */
    func setImage(_ imageData: Data, forKey key: String) {
        cache.setObject(NSData(data: imageData), forKey: NSString(string: key))
    }
}
