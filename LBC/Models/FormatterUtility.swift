//
//  FormatterUtility.swift
//  LBC
//
//  Created by Berserk on 22/07/2024.
//

import Foundation

protocol FormatterUtilityInterface {
    func formatDateFrom(string date: String) -> String
    func formatSiret(from siret: String?) -> String?
    func formatPrice(from price: CGFloat) -> String
    func formatError(_ error: NetworkServiceError) -> AlertErrorModel
}

struct FormatterUtility: FormatterUtilityInterface {
    
    static let shared = FormatterUtility()
    
    private let dateFormatter = DateFormatter()
    private let priceFormatter = NumberFormatter()

    /// Use this method to reformat a date String.
    func formatDateFrom(string date: String) -> String {
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        guard let formattedDate = dateFormatter.date(from: date) else {
            return date
        }
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: formattedDate)
    }
    
    /// Use this method to format the siret String.
    func formatSiret(from siret: String?) -> String? {
        
        guard let unwrappedSiret = siret else {
            return nil
        }
        
        return "Siret: \(String(describing: unwrappedSiret))"
    }
    
    /// Use this method to format price to a String.
    func formatPrice(from price: CGFloat) -> String {
        priceFormatter.numberStyle = .currency
        priceFormatter.currencyCode = Locale.current.currencyCode ?? "EUR"
        
        // Not selling free products here :p
        guard price > 0.0, let stringPrice = priceFormatter.string(from: NSNumber(floatLiteral: price)) else { return Constants.HomeCollectionViewCell.invalidPriceText }
        return stringPrice
    }
    
    /// Uses this method to format an Error to a String.
    func formatError(_ error: NetworkServiceError) -> AlertErrorModel {
        
        let title: String = "La requête a échoué"
        let errorMessage: String
        
        switch error {
        case .invalidUrl:
            errorMessage = "L'url n'est pas valide."
        case .invalidResponse:
            errorMessage = "La réponse n'est pas valide."
        case .requestFailed:
            errorMessage = "Vérifiez votre connexion internet et réessayez !"
        case .decodingFailed:
            errorMessage = "Le décodage des données a échoué"
        case .cancelled:
            errorMessage = "La requête a été annulée."
        case .unauthorized:
            errorMessage = "La requête n'est pas autorisée."
        case .serverFailed:
            errorMessage = "Le serveur a rencontré une erreur."
        case .unknown:
            errorMessage = "Une erreur inconnue s'est produite."

        }
        
        return AlertErrorModel(title: title, message: errorMessage)
    }
}
