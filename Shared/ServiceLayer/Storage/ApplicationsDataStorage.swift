//
//  ApplicationsDataStorage.swift
//  Miqi
//
//  Created by Elena Gordienko on 26.03.2022.
//

import Intents
import Foundation
import SwiftUI

final class ApplicationsDataStorage {
    private let storage = UserDefaults(suiteName: Constants.appGroup)
    
    func getAppStats(for application: Application) -> AppStats? {
        guard
            let dictionary = getAppStatsDictionary(),
            let appStatsDictionary = dictionary["\(application.rawValue)"],
            let jsonData = try? JSONSerialization.data(withJSONObject: appStatsDictionary)
        else {
            print("Failed to get data for app #\(application.name)")
            return nil
        }
        return try? JSONDecoder().decode(AppStats.self, from: jsonData)
    }
    
    func saveAppStats(_ appStats: AppStats, for application: Application) {
        var dictionary = getAppStatsDictionary() ?? [:]
        dictionary["\(application.rawValue)"] = appStats.asDictionary()
        storage?.set(dictionary, forKey: Constants.appStatsStorage)
    }
    
    private func getAppStatsDictionary() -> [String: Any]? {
        guard
            let dictionary = storage?.object(forKey: Constants.appStatsStorage),
            let applicationData = dictionary as? [String: Any]
        else {
            print("Failed to get userDefaults")
            return nil
        }
        return applicationData
    }
}

