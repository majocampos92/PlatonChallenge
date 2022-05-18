//
//  CloseAppIntentHandler.swift
//  MiqiShortcutIntent
//
//  Created by Elena Gordienko on 07.04.2022.
//

import Foundation
import Intents

final class CloseAppIntentHandler: NSObject, CloseAppIntentHandling {
    let attemptsCounter = AttemptsCounter()
    /// This method should not perform any computations.
    /// It should return as soon as possible, otherwise the intent would fail.
    /// All the work should be done while processing corresponding user activities.
    @objc(handleCloseApp:completion:)
    func handle(
        intent: CloseAppIntent,
        completion: @escaping (CloseAppIntentResponse) -> Void
    ) {
        let date = Date.now
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.attemptsCounter.updateTotalTimeSpent(
                on: intent.applicationName,
                date: date
            )
        }
        completion(CloseAppIntentResponse(code: .success, userActivity: nil))
    }
}

