//
//  AttemptsCounter.swift
//  Miqi
//
//  Created by Elena Gordienko on 28.03.2022.
//

import Foundation

final class AttemptsCounter {
    let storage = ApplicationsDataStorage()
    
    var calendar: Calendar {
        var currentCalendar = Calendar.current
        currentCalendar.timeZone = .current
        return currentCalendar
    }
    
    func updatedOpeningAttemptsCount(for app: Application) -> AppStats {
        var appStats = storage.getAppStats(for: app) ?? .init()
        let currentDate = Date.now
        let lastDayAttempts = appStats.attemptDates.filter {
            // TODO: consider comparing two dates approximately
            // if the difference between two dates lies within some small delta range
            areTheSameDay($0, currentDate)
        }
        let shouldResetTotalTime: Bool
        if let lastDayAttempt = lastDayAttempts.last, let lastAttempt = appStats.attemptDates.last {
            shouldResetTotalTime = !areTheSameDay(lastDayAttempt, lastAttempt)
        } else {
            shouldResetTotalTime = true
        }
        appStats.attemptDates = lastDayAttempts + [currentDate]
        appStats.totalTimeSpent = shouldResetTotalTime ? 0 : appStats.totalTimeSpent
        storage.saveAppStats(appStats, for: app)
        return appStats
    }
    
    func updateTotalTimeSpent(on app: Application, date: Date) {
        guard
            var appStats = storage.getAppStats(for: app),
            let lastAttempt: Date = appStats.attemptDates.last
        else {
            // invalid situation (no info on app opening, but has info on app closing)
            storage.saveAppStats(.init(attemptDates: [date], lastCloseDate: date), for: app)
            return
        }
        let timeSpent = areTheSameDay(date, lastAttempt)
            ? appStats.totalTimeSpent + date.timeIntervalSince(lastAttempt)
            : date.timeIntervalSince(startOfDay(for: date))
        appStats.totalTimeSpent = timeSpent
        appStats.lastCloseDate = date
        storage.saveAppStats(appStats, for: app)
        return
    }
    
    private func areTheSameDay(_ lhs: Date, _ rhs: Date) -> Bool {
        return calendar.compare(lhs, to: rhs, toGranularity: .day) == .orderedSame
            && calendar.compare(lhs, to: rhs, toGranularity: .month) == .orderedSame
            && calendar.compare(lhs, to: rhs, toGranularity: .year) == .orderedSame
    }
    
    private func startOfDay(for date: Date) -> Date {
        calendar.startOfDay(for: date)
    }
}
