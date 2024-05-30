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
        
        let categoriesData = loadMock(name: "categories", ext: "json")
        let productsData = loadMock(name: "products", ext: "json")
        
        mockNetworkService.categoriesPublisher = Just(categoriesData)
            .setFailureType(to: NetworkServiceError.self)
            .eraseToAnyPublisher()
        
        mockNetworkService.productsPublisher = Just(productsData)
            .setFailureType(to: NetworkServiceError.self)
            .eraseToAnyPublisher()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
        mockNetworkService = nil
        viewModel = nil
    }
    
    func testCategoryId() {
        
        let expectation = XCTestExpectation(description: "Successfully fetched categoryIds")
        
        viewModel.$products
            .dropFirst()
            .sink { products in
                XCTAssertEqual(products[0].categoryId, 4)
                XCTAssertEqual(products[1].categoryId, 8)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.start()
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testCategoryStringIsCompleted() {
        
        let expectation = XCTestExpectation(description: "Successfully fetched data")
        
        viewModel.$products
            .dropFirst()
            .sink { products in
                XCTAssertEqual(products[0].category, "Maison")
                XCTAssertEqual(products[1].category, "Multimédia")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.start()
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testTitle() {
        
        let expectation = XCTestExpectation(description: "Successfully fetched titles")
        
        viewModel.$products
            .dropFirst()
            .sink { products in
                XCTAssertEqual(products[0].title, "Statue homme noir assis en plâtre polychrome")
                XCTAssertEqual(products[1].title, "Pc portable hp elitebook 820 g1 core i5 4 go ram 250 go hdd")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.start()
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testDescription() {
        
        let expectation = XCTestExpectation(description: "Successfully fetched descriptions")
        
        viewModel.$products
            .dropFirst()
            .sink { products in
                XCTAssertEqual(products[0].description, "Magnifique Statuette homme noir assis fumant le cigare en terre cuite et plâtre polychrome réalisée à la main.  Poids  1,900 kg en très bon état, aucun éclat  !  Hauteur 18 cm  Largeur : 16 cm Profondeur : 18cm  Création Jacky SAMSON  OPTIMUM  PARIS  Possibilité de remise sur place en gare de Fontainebleau ou Paris gare de Lyon, en espèces (heure et jour du rendez-vous au choix). Envoi possible ! Si cet article est toujours visible sur le site c'est qu'il est encore disponible")
                XCTAssertEqual(products[1].description, "= = = = = = = = = PC PORTABLE HP ELITEBOOK 820 G1 = = = = = = = = = # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # HP ELITEBOOK 820 G1 Processeur : Intel Core i5 4300M Fréquence : 2,60 GHz Mémoire : 4 GO DDR3 Disque Dur : 320 GO SATA Vidéo : Intel HD Graphics Lecteur Optique : Lecteur/Graveur CD/DVDRW Réseau : LAN 10/100 Système : Windows 7 Pro – 64bits Etat : Reconditionné  Garantie : 6 Mois Prix TTC : 199,00 € Boostez ce PC PORTABLE : Passez à la vitesse supérieure en augmentant la RAM : Passez de 4 à 6 GO de RAM pour 19€  Passez de 4 à 8 GO de RAM pour 29€  (ajout rapide, doublez la vitesse en 5 min sur place !!!) Stockez plus en augmentant la capacité de votre disque dur : Passez en 500 GO HDD pour 29€  Passez en 1000 GO HDD pour 49€  Passez en 2000 GO HDD pour 89€  Passez en SSD pour un PC 10 Fois plus rapide : Passez en 120 GO SSD pour 49€  Passez en 240 GO SSD pour 79€  Passez en 480 GO SSD pour 119€ # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # Nous avons plus de 300 Ordinateurs PC Portables. Visible en boutique avec une garantie de 6 mois vendu avec Facture TVA, pas de surprise !!!! Les prix varient en moyenne entre 150€ à 600€, PC Portables en stock dans notre boutique sur Paris. # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # KIATOO est une société qui regroupe à la fois: - PC Portable - PC de Bureau / Fixe - Chargeur PC Portable - Batterie PC Portable - Clavier PC Portable - Ventilateur PC Portable - Nappe LCD écran - Ecran LCD PC Portable - Mémoire PC Portable - Disque dur PC Portable - Inverter PC Portable - Connecteur Jack DC PC Portable ASUS, ACER, COMPAQ, DELL, EMACHINES, HP, IBM, LENOVO, MSI, PACKARD BELL, PANASONIC, SAMSUNG, SONY, TOSHIBA...")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.start()
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testPrice() {
        
        let expectation = XCTestExpectation(description: "Successfully fetched prices")
        
        viewModel.$products
            .dropFirst()
            .sink { products in
                XCTAssertEqual(products[0].price, 140.00)
                XCTAssertEqual(products[1].price, 199.00)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.start()
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testImagesUrl() {
        
        let expectation = XCTestExpectation(description: "Successfully fetched imagesUrl")
        
        viewModel.$products
            .dropFirst()
            .sink { products in
                XCTAssertEqual(products[0].imagesUrl.small, "https://raw.githubusercontent.com/leboncoin/paperclip/master/ad-small/2c9563bbe85f12a5dcaeb2c40989182463270404.jpg")
                XCTAssertEqual(products[0].imagesUrl.thumb, "https://raw.githubusercontent.com/leboncoin/paperclip/master/ad-thumb/2c9563bbe85f12a5dcaeb2c40989182463270404.jpg")
                XCTAssertEqual(products[2].imagesUrl.small, nil)
                XCTAssertEqual(products[2].imagesUrl.thumb, nil)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.start()
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testCreationDate() {
        
        let expectation = XCTestExpectation(description: "Successfully fetched creationDate")
        
        viewModel.$products
            .dropFirst()
            .sink { products in
                XCTAssertEqual(products[0].creationDate, "2019-11-05T15:56:59+0000")
                XCTAssertEqual(products[1].creationDate, "2019-10-16T17:10:20+0000")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.start()
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testIsUrgent() {
        
        let expectation = XCTestExpectation(description: "Successfully fetched isUrgent")
        
        viewModel.$products
            .dropFirst()
            .sink { products in
                XCTAssertEqual(products[0].isUrgent, false)
                XCTAssertEqual(products[2].isUrgent, true)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.start()
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testSiret() {
        
        let expectation = XCTestExpectation(description: "Successfully fetched optional siret")
        
        viewModel.$products
            .dropFirst()
            .sink { products in
                XCTAssertEqual(products[0].siret, nil)
                XCTAssertEqual(products[3].siret, "123 323 002")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.start()
        
        wait(for: [expectation], timeout: 5.0)
    }

}
