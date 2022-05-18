//
//  MiqiApp.swift
//  Miqi
//
//  Created by Elena Gordienko on 26.03.2022.
//

import Intents
import SwiftUI

@main
struct MiqiApp: App {
    @Environment(\.scenePhase) var scenePhase
    
    @State private var showingPopupView = false
    @StateObject var openAttemptInfo = OpenAttemptInfo()
    
    private let attemptsCounter = AttemptsCounter()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
            .fullScreenCover(isPresented: $showingPopupView) {
                PopupView(openAttemptInfo: openAttemptInfo)
            }.userActivity(Constants.openAppUserActivity) { userActivity in
                userActivity.isEligibleForSearch = false
            }
            .onContinueUserActivity(Constants.openAppUserActivity) { userActivity in
                showingPopupView = true
                processOpeningAppActivity(userInfo: userActivity.userInfo)
            }.onChange(of: scenePhase) { newScenePhase in
                processScenePhaseChange(to: newScenePhase)
            }
        }
    }
    
    private func processScenePhaseChange(to phase: ScenePhase) {
        switch phase {
        case .active, .background:
            break
        case .inactive:
            showingPopupView = false
        @unknown default:
            break
        }
    }
    
    private func processOpeningAppActivity(userInfo: [AnyHashable : Any]?) {
        guard
            let userInfo = userInfo as? [String: Any],
            let appIdentifier = userInfo[Constants.openAppUserInfoKey] as? Int,
            let appName = Application(rawValue: appIdentifier)
        else {
            print("OpenApp failed: no user info provided")
            return
        }
        let appStats = attemptsCounter.updatedOpeningAttemptsCount(for: appName)
        openAttemptInfo.app = appName
        let openIntentCalls = appStats.attemptDates.count
        // open intent handler is called whenever the target app becomes active
        // so the same attempt is counted twice whenever the breathing exercise is triggered
        openAttemptInfo.attemptsNumber =  openIntentCalls / 2 + openIntentCalls % 1
        openAttemptInfo.timeSpent = appStats.totalTimeSpent
    }
}
