//
//  FormatterUtility.swift
//  LBC
//
//  Created by Berserk on 22/07/2024.
//

import Foundation

struct FormatterUtility {
    
    /// Use this method to reformat a date String.
    static func formatDateFrom(string date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        guard let formattedDate = dateFormatter.date(from: date) else {
            return date
        }
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: formattedDate)
    }
    
    /// Use this method to format the siret String.
    static func formatSiret(from siret: String?) -> String? {
        
        guard let unwrappedSiret = siret else {
            return nil
        }
        
        return "Siret: \(String(describing: unwrappedSiret))"
    }
    
    /// Use this method to format price to a String.
    static func formatPrice(from price: CGFloat) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = Locale.current.currencyCode ?? "EUR"
        
        // Not selling free products here :p
        guard price > 0.0, let stringPrice = formatter.string(from: NSNumber(floatLiteral: price)) else { return Constants.HomeCollectionViewCell.invalidPriceText }
        return stringPrice
    }
    
    /// Uses this method to format an Error to a String.
    static func formatError(_ error: NetworkServiceError) -> AlertErrorModel {
        
        let title: String = "Le téléchargement de l'image a échoué."
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
        case .statusCode(let statusCode):
            switch statusCode {
            case 400..<500:
                errorMessage = "La requête n'est pas autorisée."
            case 500..<600:
                errorMessage = "Le serveur a rencontré une erreur."
            default:
                errorMessage = error.localizedDescription
            }
        case .unknown(let error):
            errorMessage = error.localizedDescription
        case .cancelled:
            errorMessage = "La requête est annulée."
        }
        
        return AlertErrorModel(title: title, message: errorMessage)
    }
}
