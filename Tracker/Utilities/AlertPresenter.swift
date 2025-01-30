//
//  AlertPresenter.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 16.10.2024.
//

import UIKit

enum AlertButton: String {
    case deleteButton
    case cancelButton

    var accessibilityIdentifier: String {
        switch self {
        case .deleteButton:
            return "Delete Button"
        case .cancelButton:
            return "Cancel Button"
        }
    }

    var title: String {
        switch self {
        case .deleteButton:
            return NSLocalizedString("buttonDelete", comment: "")
        case .cancelButton:
            return NSLocalizedString("buttonCancel", comment: "")
        }
    }
}

struct AlertPresenter {
    static func showAlert(on viewController: UIViewController,
                          model: AlertModel) {
        showBasicAlert(
            on: viewController,
            title: model.title,
            message: model.message,
            buttons: model.buttons,
//            identifier: model.identifier,
            completion: model.completion ?? {}
        )
    }

    private static func showBasicAlert(
        on viewController: UIViewController,
        title: String?,
        message: String?,
        buttons: [AlertButton],
//        identifier: String,
        completion: @escaping () -> Void
    ) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .actionSheet)
        alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = .systemBackground
//        alert.view.accessibilityIdentifier = identifier

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
            viewController.present(alert, animated: true)
        }
    }
}
