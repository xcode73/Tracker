//
//  UITAbBar+TopBorder.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 03.02.2025.
//

import UIKit

extension UITabBar {
    func addTopBorder(color: UIColor, height: CGFloat) {
        let borderLayer = CALayer()
        borderLayer.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: height)
        borderLayer.backgroundColor = color.cgColor
        self.layer.addSublayer(borderLayer)
    }
}
