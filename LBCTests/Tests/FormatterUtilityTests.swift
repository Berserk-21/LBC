//
//  FormatterUtilityTests.swift
//  LBCTests
//
//  Created by Berserk on 23/07/2024.
//

import XCTest
@testable import LBC

class FormatterUtilityTests: XCTestCase {
    
    var formattedUtility: FormatterUtility!
    
    override func setUp() {
        super.setUp()
        formattedUtility = FormatterUtility.shared
    }
    
    override func tearDown() {
        formattedUtility = nil
        super.tearDown()
    }
    
    func testFormatDate_success() {
        
        let initialDate = "2019-11-05T15:56:59+0000"
        let expectedResult = "5 Nov 2019"
        let result = formattedUtility.formatDateFrom(string: initialDate)
        
        XCTAssertEqual(result, expectedResult)
    }
    
    func testFormatDate_failure() {
        
        let initialDate = "2019-11-05"
        let expectedResult = "5 Nov 2019"
        let result = formattedUtility.formatDateFrom(string: initialDate)
        
        XCTAssertNotEqual(result, expectedResult)
    }
    
    func testFormatSiret_success() {
        
        let siret = "123 323 002"
        let expectedResult = "Siret: \(String(describing: siret))"
        let result = formattedUtility.formatSiret(from: siret)
        
        XCTAssertEqual(result, expectedResult)
    }
    
    func testFormatSiret_nil() {
        
        let expectedResult: String? = nil
        let result = formattedUtility.formatSiret(from: nil)
        
        XCTAssertEqual(result, expectedResult)
    }
    
    func testFormatPrice_success() {
        
        let price = 200.0
        let expectedResult = "€200,00"
        let result = formattedUtility.formatPrice(from: price)
        
        XCTAssertEqual(result, expectedResult)
    }
    
    func testFormatPrice_failure() {
        
        let price = -1.0
        let expectedResult = "Prix inconnu"
        let result = formattedUtility.formatPrice(from: price)
        
        XCTAssertEqual(result, expectedResult)
    }
    
    func testFormatError_invalidUrl() {
        
        let error = NetworkServiceError.invalidUrl
        let expectedTitle: String = "La requête a échoué"
        let expectedMessage: String = "L'url n'est pas valide."
        
        let resultTitle = formattedUtility.formatError(.invalidUrl).title
        let resultMessage = formattedUtility.formatError(.invalidUrl).message
        
        XCTAssertEqual(resultTitle, expectedTitle)
        XCTAssertEqual(resultMessage, expectedMessage)
    }
    
    func testFormatError_invalidResponse() {
        
        let error = NetworkServiceError.invalidResponse
        let expectedTitle: String = "La requête a échoué"
        let expectedMessage: String = "La réponse n'est pas valide."
        
        let resultTitle = formattedUtility.formatError(.invalidResponse).title
        let resultMessage = formattedUtility.formatError(.invalidResponse).message
        
        XCTAssertEqual(resultTitle, expectedTitle)
        XCTAssertEqual(resultMessage, expectedMessage)
    }
    
    func testFormatError_requestFailed() {
        
        let error = NetworkServiceError.requestFailed
        let expectedTitle: String = "La requête a échoué"
        let expectedMessage: String = "Vérifiez votre connexion internet et réessayez !"
        
        let resultTitle = formattedUtility.formatError(error).title
        let resultMessage = formattedUtility.formatError(error).message
        
        XCTAssertEqual(resultTitle, expectedTitle)
        XCTAssertEqual(resultMessage, expectedMessage)
    }
    
    func testFormatError_decodingFailed() {
        
        let error = NetworkServiceError.decodingFailed
        let expectedTitle: String = "La requête a échoué"
        let expectedMessage: String = "Le décodage des données a échoué"
        
        let resultTitle = formattedUtility.formatError(error).title
        let resultMessage = formattedUtility.formatError(error).message
        
        XCTAssertEqual(resultTitle, expectedTitle)
        XCTAssertEqual(resultMessage, expectedMessage)
    }
    
    func testFormatError_cancelled() {
        
        let error = NetworkServiceError.cancelled
        let expectedTitle: String = "La requête a échoué"
        let expectedMessage: String = "La requête a été annulée."
        
        let resultTitle = formattedUtility.formatError(error).title
        let resultMessage = formattedUtility.formatError(error).message
        
        XCTAssertEqual(resultTitle, expectedTitle)
        XCTAssertEqual(resultMessage, expectedMessage)
    }
    
    func testFormatError_unauthorized() {
        
        let expectedTitle: String = "La requête a échoué"
        let expectedMessage: String = "La requête n'est pas autorisée."
        let error = NetworkServiceError.unauthorized

        let resultTitle = formattedUtility.formatError(error).title
        let resultMessage = formattedUtility.formatError(error).message
        
        XCTAssertEqual(resultTitle, expectedTitle)
        XCTAssertEqual(resultMessage, expectedMessage)
    }
    
    func testFormatError_serverFailed() {
        
        let expectedTitle: String = "La requête a échoué"
        let expectedMessage: String = "Le serveur a rencontré une erreur."
        let error = NetworkServiceError.serverFailed
        
        let resultTitle = formattedUtility.formatError(error).title
        let resultMessage = formattedUtility.formatError(error).message
        
        XCTAssertEqual(resultTitle, expectedTitle)
        XCTAssertEqual(resultMessage, expectedMessage)
    }
    
    func testFormatError_unknown() {
        
        let expectedTitle: String = "La requête a échoué"
        let expectedMessage: String = "Une erreur inconnue s'est produite."
        let error = NetworkServiceError.unknown
        
        let resultTitle = formattedUtility.formatError(error).title
        let resultMessage = formattedUtility.formatError(error).message
        
        XCTAssertEqual(resultTitle, expectedTitle)
        XCTAssertEqual(resultMessage, expectedMessage)
    }
}
