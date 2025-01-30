//
//  Category.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 21.11.2024.
//
//

import CoreData

@objc(Category)
public class Category: NSManagedObject, Identifiable {
    @NSManaged public var title: String
    @NSManaged public var trackers: NSSet?
}
