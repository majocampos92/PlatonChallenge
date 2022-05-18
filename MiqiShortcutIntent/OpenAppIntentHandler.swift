//
//  OpenAppHandler.swift
//  MiqiShortcutIntent
//
//  Created by Elena Gordienko on 07.04.2022.
//

import Foundation
import Intents

final class OpenAppIntentHandler: NSObject, OpenAppIntentHandling {
    /// This method should not perform any computations.
    /// It should return as soon as possible, otherwise the intent would fail.
    /// All the work should be done while processing corresponding user activities.
    @objc(handleOpenApp:completion:)
    func handle(
        intent: OpenAppIntent,
        completion: @escaping (OpenAppIntentResponse) -> Void
    ) {
        if AppOpeningGuardService.shared.shouldAllowOpening(intent.applicationName) {
            completion(OpenAppIntentResponse(code: .success, userActivity: nil))
            return
        }
        let userActivity = NSUserActivity(activityType: Constants.openAppUserActivity)
        userActivity.userInfo = [Constants.openAppUserInfoKey: intent.applicationName.rawValue]
        completion(OpenAppIntentResponse(code: .continueInApp, userActivity: userActivity))
    }
}
