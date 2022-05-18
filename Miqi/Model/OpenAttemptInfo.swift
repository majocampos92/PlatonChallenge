//
//  OpenAttemptInfo.swift
//  Miqi
//
//  Created by Elena Gordienko on 27.03.2022.
//

import Foundation

final class OpenAttemptInfo: ObservableObject {
    @Published var attemptsNumber: Int?
    @Published var app: Application?
    @Published var timeSpent: TimeInterval?
    
    init(
        attemptsNumber: Int? = nil,
        app: Application? = nil,
        timeSpent: TimeInterval? = nil
    ) {
        self.attemptsNumber = attemptsNumber
        self.app = app
        self.timeSpent = timeSpent
    }
}
