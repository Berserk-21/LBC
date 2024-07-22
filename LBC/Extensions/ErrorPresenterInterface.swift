//
//  ErrorPresenter.swift
//  LBC
//
//  Created by Berserk on 22/07/2024.
//

import UIKit

protocol ErrorPresenterInterface {
    func presentError(title: String, message: String, on viewController: UIViewController)
}

extension ErrorPresenterInterface {
    func presentError(title: String, message: String, on viewController: UIViewController) {
        let title: String = Constants.ProductViewController.Alert.errorTitle
        let message: String = message
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: Constants.ProductViewController.Alert.okTitle, style: .default, handler: nil))
        viewController.present(alertController, animated: true)
    }
    
}

struct AlertErrorModel {
    let title: String
    let message: String
}
