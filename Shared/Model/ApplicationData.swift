//
//  ApplicationData.swift
//  Miqi
//
//  Created by Elena Gordienko on 26.03.2022.
//

import Foundation

extension Application: Codable & Hashable { }

public struct AppStats: Codable {
    var attemptDates: [Date]
    var lastCloseDate: Date?
    var didProceedDate: Date?
    var totalTimeSpent: TimeInterval

    public init(
        attemptDates: [Date] = [],
        lastCloseDate: Date? = nil,
        didProceedDate: Date? = nil,
        totalTimeSpent: TimeInterval = 0
    )  {
        self.attemptDates = attemptDates
        self.totalTimeSpent = totalTimeSpent
        self.didProceedDate = didProceedDate
        self.lastCloseDate = lastCloseDate
    }
}
