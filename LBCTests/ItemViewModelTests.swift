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

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let data = loadMock(name: "itemProducts", ext: "json")
        let products = try! JSONDecoder().decode([ProductModel].self, from: data)
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolMock.self]
        let session = URLSession(configuration: config)
        itemViewModels = [ProductDetailViewModel(product: products[0], urlSession: session), ProductDetailViewModel(product: products[1])]
    }

    override func tearDownWithError() throws {
        itemViewModels = nil
        cancellables = []
    }

    func testFormattedPrice() {
        XCTAssertEqual(itemViewModels[0].formattedPrice, "€140,00")
        XCTAssertEqual(itemViewModels[1].formattedPrice, Constants.HomeCollectionViewCell.invalidPriceText)
    }
    
    func testFormattedDate() {
        XCTAssertEqual(itemViewModels[0].formattedDate, "5 Nov 2019")
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
        XCTAssertEqual(itemViewModels[0].formattedSiret!, "Siret: 3549394390")
        XCTAssertNil(itemViewModels[1].formattedSiret)
    }
    
    func testImagesUrl() {
        XCTAssertEqual(itemViewModels[0].thumbImageUrlString, "https://raw.githubusercontent.com/leboncoin/paperclip/master/ad-thumb/2c9563bbe85f12a5dcaeb2c40989182463270404.jpg")
        XCTAssertNil(itemViewModels[1].thumbImageUrlString)
    }
    
    func testLoadImage() {
        
        let expectation = self.expectation(description: "Successfully fetched image")
        
        let imageUrl = URL(string: itemViewModels[0].thumbImageUrlString!)
        let testImageData = (UIImage(named: "thumb_test")?.pngData())!
        
        URLProtocolMock.testURLs = [imageUrl: testImageData]
        URLProtocolMock.loadingHandler = { request in
            return (HTTPURLResponse(), testImageData)
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
}
