//
//  AlertPresenter.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 16.10.2024.
//

import UIKit

enum AlertButton: String {
    case deleteButton = "Удалить"
    case cancelButton = "Отменить"
    
    var accessibilityIdentifier: String {
        return self.rawValue
    }
    
    var title: String {
        return self.rawValue
    }
}

struct AlertPresenter {
    static func showAlert(on vc: UIViewController, model: AlertModel) {
        showBasicAlert(
            on: vc,
            title: model.title,
            message: model.message,
            buttons: model.buttons,
            identifier: model.identifier,
            completion: model.completion ?? {}
        )
    }
    
    private static func showBasicAlert(
        on vc: UIViewController,
        title: String?,
        message: String?,
        buttons: [AlertButton],
        identifier: String,
        completion: @escaping () -> Void
    ) {
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .actionSheet)
        
        alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = .systemBackground
        
        alert.view.accessibilityIdentifier = identifier
        
        for button in buttons {
            switch button {
            case .deleteButton:
                let action = UIAlertAction(title: button.title, style: .destructive) { _ in
                    DispatchQueue.main.async {
                        completion()
                    }
                }
                action.accessibilityIdentifier = button.accessibilityIdentifier
                alert.addAction(action)
            default:
                let action = UIAlertAction(title: button.title, style: .cancel, handler: nil)
                action.accessibilityIdentifier = button.accessibilityIdentifier
                alert.addAction(action)
            }
        }
        
        DispatchQueue.main.async {
            vc.present(alert, animated: true)
        }
    }
}

