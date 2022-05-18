//
//  AppOpeningGuardService.swift
//  Miqi
//
//  Created by Elena Gordienko on 27.03.2022.
//

import Foundation

final class AppOpeningGuardService {
    private let storage = ApplicationsDataStorage()
    
    static let shared: AppOpeningGuardService = .init()
   
    private init() { }
    
    /// Decides whether to allow user to open the `application`
    /// - parameters:
    /// - application: the application user tries to open
    /// - returns:
    /// whether user can open the app without triggering breathing exercise
    func shouldAllowOpening(_ application: Application) -> Bool {
        let currentDate = Date.now
        let savedAppStats = storage.getAppStats(for: application)
        
        var appStats: AppStats
        defer { storage.saveAppStats(appStats, for: application) }
        guard savedAppStats != nil  else {
            appStats = .init(attemptDates: [currentDate])
            return false
        }
        appStats = savedAppStats!
        appStats.attemptDates = appStats.attemptDates + [currentDate]
        guard
            // if isLastCloseWithinAMinute is nil, this is either the very first opening for this app after configuring the automation,
            // or the situation when first closing automation haven't finish yet,
            // or an incosistent state
            let isLastCloseWithinAMinute = appStats.lastCloseDate.map({
                currentDate.timeIntervalSince($0) < 60.0
            }),
            // if this app was closed and then reopened more than after a minute, it is considered as a new open attempt
            // (another session)
            isLastCloseWithinAMinute
        else {
            // this checks for the situation when close intent wasn't triggered fast enough to update lastCloseDate
            guard let didProceedDate = appStats.didProceedDate else { return false }
            // check whether user chose to proceed within 3 seconds from current date
            if currentDate.timeIntervalSince(didProceedDate) < 3 {
                // the session is authorized
                return true
            } else {
                // the session is not authorized, resetting last permission date
                appStats.didProceedDate = nil
                return false
            }
        }
        // checking whether this session was "authorized" (user deliberately chose to continue with this app)
        return appStats.didProceedDate != nil
    }
    
    /// Updates app stats in the storage for chosen `application` with `didProceedDate`
    /// - parameters:
    /// - application: the application user tries to open
    /// - appStats: data connected with the application (should pass `nil` if this method is triggered within view code)
    /// - didUserChooseToProceed: value for the corresponding field in `appStats` to be saved
    func updateDidProceed(for application: Application, with didProceedDate: Date?) {
        var appStats = storage.getAppStats(for: application) ?? .init()
        appStats.didProceedDate = didProceedDate
        storage.saveAppStats(appStats, for: application)
    }
}
