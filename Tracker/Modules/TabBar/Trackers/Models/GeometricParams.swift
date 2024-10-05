//
//  GeometricParams.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 30.09.2024.
//

import Foundation

struct GeometricParams {
    let cellCount: CGFloat
    let topInset: CGFloat
    let bottomInset: CGFloat
    let leftInset: CGFloat
    let rightInset: CGFloat
    let cellSpacing: CGFloat
    let cellHeight: CGFloat
    let paddingWidth: CGFloat
    let lineSpacing: CGFloat
    let headerHeight: CGFloat
    
    init(
        cellCount: CGFloat,
        topInset: CGFloat,
        bottomInset: CGFloat,
        leftInset: CGFloat,
        rightInset: CGFloat,
        cellSpacing: CGFloat,
        cellHeight: CGFloat,
        lineSpacing: CGFloat,
        headerHeight: CGFloat
    ) {
        self.cellCount = cellCount
        self.topInset = topInset
        self.bottomInset = bottomInset
        self.leftInset = leftInset
        self.rightInset = rightInset
        self.cellSpacing = cellSpacing
        self.cellHeight = cellHeight
        self.lineSpacing = lineSpacing
        self.headerHeight = headerHeight
        self.paddingWidth = leftInset + rightInset + CGFloat(cellCount - 1) * cellSpacing
    }
}
