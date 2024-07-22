//
//  ErrorPresenter.swift
//  LBC
//
//  Created by Berserk on 22/07/2024.
//

import UIKit

protocol ErrorPresenter {
    func presentError(_ error: Error, on viewController: UIViewController)
}

extension ErrorPresenter {
    func presentError(_ error: Error, on viewController: UIViewController) {
        let title: String = Constants.ProductViewController.Alert.errorTitle
        let message: String = Constants.ProductViewController.Alert.errorMessage
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: Constants.ProductViewController.Alert.okTitle, style: .default, handler: nil))
        viewController.present(alertController, animated: true)
    }
}
