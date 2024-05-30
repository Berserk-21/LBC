//
//  LBCTests.swift
//  LBCTests
//
//  Created by Berserk on 29/05/2024.
//

import XCTest
import Combine
@testable import LBC

final class LBCTests: XCTestCase {
    
    var viewModel: HomeViewModel!
    var mockNetworkService: MockNetworkService!
    var cancellables = Set<AnyCancellable>()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        mockNetworkService = MockNetworkService()
        viewModel = HomeViewModel(networkService: mockNetworkService)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
        mockNetworkService = nil
        viewModel = nil
    }
    
    func testFetchDataSuccess() {
        
        let categoriesData = loadMock(name: "categories", ext: "json")
        let productsData = loadMock(name: "products", ext: "json")
        
        mockNetworkService.categoriesPublisher = Just(categoriesData)
            .setFailureType(to: NetworkServiceError.self)
            .eraseToAnyPublisher()
        
        mockNetworkService.productsPublisher = Just(productsData)
            .setFailureType(to: NetworkServiceError.self)
            .eraseToAnyPublisher()
        
        let expectation = XCTestExpectation(description: "Successfully fetched data")
        
        viewModel.$products
            .dropFirst()
            .sink { products in
                print("products.count, ",products.count)
                XCTAssertEqual(products[0].category, "Maison")
                XCTAssertEqual(products[1].category, "Multimédia")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.start()
        
        wait(for: [expectation], timeout: 5.0)
    }

}
