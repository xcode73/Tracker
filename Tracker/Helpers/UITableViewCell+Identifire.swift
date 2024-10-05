//
//  UITableViewCell+Identifire.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 28.09.2024.
//

import Foundation

import UIKit

/// This extension provides a computed static property reuseIdentifier that returns the string representation of the class name.
extension UITableViewCell {
    
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
