//
//  ItemViewModelTests.swift
//  LBCTests
//
//  Created by Berserk on 30/05/2024.
//

import XCTest
import Combine
@testable import LBC

final class ItemViewModelTests: XCTestCase {
    
    var itemViewModels: [ProductDetailViewModel]!
    var cancellables = Set<AnyCancellable>()
    var session: URLSession!
    
    var fetchImageService: FetchImageServiceInterface!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let data = loadMock(name: "itemProducts", ext: "json")
        let products = try! JSONDecoder().decode([ProductModel].self, from: data)
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolMock.self]
        session = URLSession(configuration: config)
        fetchImageService = FetchImageService(session: session)
        
        itemViewModels = [ProductDetailViewModel(product: products[0]), ProductDetailViewModel(product: products[1])]
    }

    override func tearDownWithError() throws {
        itemViewModels = nil
        cancellables = []
    }

    func testFormattedPrice() {
        XCTAssertEqual(itemViewModels[0].price, "€140,00")
        XCTAssertEqual(itemViewModels[1].price, Constants.HomeCollectionViewCell.invalidPriceText)
    }
    
    func testFormattedDate() {
        XCTAssertEqual(itemViewModels[0].date, "5 Nov 2019")
    }
    
    func testTitle() {
        XCTAssertEqual(itemViewModels[0].title, "Statue homme noir assis en plâtre polychrome")
    }
    
    func testCategory() {
        XCTAssertEqual(itemViewModels[0].category!, "Maison")
        XCTAssertEqual(itemViewModels[1].category!, "Loisirs")
    }
    
    func testIsUrgent() {
        XCTAssertEqual(itemViewModels[0].isUrgent, false)
        XCTAssertEqual(itemViewModels[1].isUrgent, true)
    }
    
    func testDescription() {
        XCTAssertEqual(itemViewModels[0].description, "Magnifique Statuette homme noir assis fumant le cigare en terre cuite et plâtre polychrome réalisée à la main.  Poids  1,900 kg en très bon état, aucun éclat  !  Hauteur 18 cm  Largeur : 16 cm Profondeur : 18cm  Création Jacky SAMSON  OPTIMUM  PARIS  Possibilité de remise sur place en gare de Fontainebleau ou Paris gare de Lyon, en espèces (heure et jour du rendez-vous au choix). Envoi possible ! Si cet article est toujours visible sur le site c'est qu'il est encore disponible")
    }
    
    func testSiret() {
        XCTAssertEqual(itemViewModels[0].siret!, "Siret: 3549394390")
        XCTAssertNil(itemViewModels[1].siret)
    }
    
    func testImagesUrl() {
        XCTAssertEqual(itemViewModels[0].imageUrlString, "https://raw.githubusercontent.com/leboncoin/paperclip/master/ad-thumb/2c9563bbe85f12a5dcaeb2c40989182463270404.jpg")
        XCTAssertNil(itemViewModels[1].imageUrlString)
    }
    
    func testLoadImage() {
        
        let expectation = self.expectation(description: "Successfully fetched image")
        
        let imageUrl = URL(string: itemViewModels[0].imageUrlString!)
        let testImageData = (UIImage(named: "thumb_test")?.pngData())!
        
        URLProtocolMock.testURLs = [imageUrl: testImageData]
        URLProtocolMock.loadingHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            let data = testImageData
            return (response, data)
        }
        
        itemViewModels[0].$imageData
            .dropFirst()
            .sink { data in
                let fetchedImageData = UIImage(data: data!)!.pngData()!
                XCTAssertEqual(fetchedImageData, testImageData)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        itemViewModels[0].loadImage()
        
        waitForExpectations(timeout: 5)
    }
    
    func testStaticResponse() {
        
        let url = URL(string: itemViewModels[0].imageUrlString!)!
        let testImageData = (UIImage(named: "thumb_test")?.pngData())!
        
        URLProtocolMock.testURLs[url] = testImageData
        
        let expectation = self.expectation(description: "Completion handler invoked")
        var receivedData: Data?
        var statusCode: Int?
        var responseError: Error?
        
        let dataTask = session.dataTask(with: url) { data, response, error in
            receivedData = data
            statusCode = (response as? HTTPURLResponse)?.statusCode
            responseError = error
            expectation.fulfill()
        }
        dataTask.resume()
        
        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssertNil(responseError)
        XCTAssertEqual(statusCode, 200)
        XCTAssertNotNil(receivedData)
        XCTAssertEqual(testImageData, receivedData)
    }
    
    func testImageDownload() {
        
        let urlString = itemViewModels[0].imageUrlString!

        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: "thumb_test", withExtension: "jpeg"), let expectedData = try? Data(contentsOf: url) else {
            XCTFail("Failed to load image from bundle")
            return
        }
        
        URLProtocolMock.testURLs = [url: expectedData]
        
        let expectation = self.expectation(description: "Completion handler invoked")
        var receivedData: Data?
        var responseError: Error?
        
        fetchImageService.fetchImage(from: urlString)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    responseError = error
                case .finished:
                    expectation.fulfill()
                }
            } receiveValue: { resultData in
                receivedData = resultData
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 5)
        
        XCTAssertNil(responseError)
        XCTAssertNotNil(receivedData!)
        XCTAssertEqual(receivedData!, expectedData)
    }
}
