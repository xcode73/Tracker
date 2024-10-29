//
//  AlertModel.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 16.10.2024.
//

import Foundation

public struct AlertModel {
    let title: String?
    let message: String?
    let buttons: [AlertButton]
    let identifier: String
    let completion: (() -> Void)?
}
