//
//  jsonService.swift
//  LBCTests
//
//  Created by Berserk on 29/05/2024.
//

import XCTest

extension XCTestCase {
    
    func loadMock(name: String, ext: String) -> Data {
        
        let bundle = Bundle(for: type(of: self))
        
        let url = bundle.url(forResource: name, withExtension: ext)
        
        return try! Data(contentsOf: url!)
    }
}
