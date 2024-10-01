//
//  AlertPresenter.swift
//  Tracker
//
//  Created by Александр Зиновьев on 20.05.2023.
//

import UIKit

final class AlertPresenter {
    private let presentingViewController: UIViewController
    
    init(presentingViewController: UIViewController) {
        self.presentingViewController = presentingViewController
    }
    
    func show(message: String?, deleteAction: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: Strings.Localizable.Alert.delete, style: .destructive) { _ in
            deleteAction?()
        }
        alertController.addAction(deleteAction)
        
        let cancelAction = UIAlertAction(title: Strings.Localizable.Alert.cancel, style: .cancel)
        alertController.addAction(cancelAction)
        
        presentingViewController.present(alertController, animated: true, completion: nil)
    }
}
