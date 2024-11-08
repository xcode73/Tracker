//
//  TrackerStorage.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 05.10.2024.
//

import Foundation

final class TrackerStorage {
    var categories: [TrackerCategory] = []
    var completedTrackers: Set<TrackerRecord> = []
    
    func loadCategories(completed: @escaping ()->() ) {

        let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let documentURL = directoryURL.appendingPathComponent("categories.json")
        
        guard let data = try? Data(contentsOf: documentURL) else { return }
        let jsonDecoder = JSONDecoder()
        do {
            categories = try jsonDecoder.decode(Array<TrackerCategory>.self, from: data)
        } catch {
            print("NOTICE: Could not load Categories data \(error.localizedDescription)")
        }
        completed()
    }
    
    func saveCategories() {
        let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let documentURL = directoryURL.appendingPathComponent("categories.json")
        let jsonEncoder = JSONEncoder()
        let data = try? jsonEncoder.encode(categories)
        do {
            try data?.write(to: documentURL, options: .noFileProtection)
        } catch {
            print("ERROR: Could not save Categories data \(error.localizedDescription)")
        }
    }
    
    func loadCompletedTrackers(completed: @escaping () -> () ) {
        let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let documentURL = directoryURL.appendingPathComponent("completedTrackers.json")
        
        guard let data = try? Data(contentsOf: documentURL) else { return }
        let jsonDecoder = JSONDecoder()
        do {
            completedTrackers = try jsonDecoder.decode(Set<TrackerRecord>.self, from: data)
        } catch {
            print("NOTICE: Could not load Completed Trackers data \(error.localizedDescription)")
        }
        completed()
    }
    
    func saveCompletedTrackers() {
        let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let documentURL = directoryURL.appendingPathComponent("completedTrackers.json")
        let jsonEncoder = JSONEncoder()
        let data = try? jsonEncoder.encode(completedTrackers)
        do {
            try data?.write(to: documentURL, options: .noFileProtection)
        } catch {
            print("ERROR: Could not save Completed Trackers data \(error.localizedDescription)")
        }
    }
}
