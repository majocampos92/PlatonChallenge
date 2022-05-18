//
//  PopupView.swift
//  Miqi
//
//  Created by Elena Gordienko on 27.03.2022.
//

import SwiftUI

struct PopupView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.openURL) var openURL
    @StateObject var openAttemptInfo: OpenAttemptInfo
    @State var animationState: AnimationState = .ready
    @State var breathingProgress = 0.0
    
    var body: some View {
        ZStack {
            gradientView
            VStack(alignment: .center, spacing: 16) {
                Spacer()
                ZStack {
                    titleView(text: "It's time to take a breath")
                        .isHidden(animationState == .final || animationState == .stopped)
                    titleView(text: "Well done!")
                        .isHidden(animationState != .final)
                    appInfo
                        .transition(.opacity)
                        .isHidden(animationState != .stopped)
                }
                ZStack {
                    BreathAnimationView(
                        color: Constants.progressViewColor,
                        animationState: $animationState
                    )
                    .padding(20)
                    progressView
                }
                .isHidden(animationState == .stopped)
                Spacer()
                Group {
                    stayInAppButton
                    continueButton
                }
                .transition(.opacity)
                .isHidden(animationState != .stopped)
            }.padding()
        }
        .onAppear {
            startBreathAnimation()
        }
        .onDisappear {
            animationState = .stopped
        }
    }
    
    var gradientView: some View {
        LinearGradient(
            gradient: Gradient(
                colors: [Constants.gradientStart, Constants.gradientEnd]),
                startPoint: UnitPoint(x: 0.5, y: 0),
                endPoint: UnitPoint(x: 0.5, y: 0.6)
        ).ignoresSafeArea()
    }
    
    var stayInAppButton: some View {
        Button("I don't want to open this app") {
            presentationMode.wrappedValue.dismiss()
        }
        .padding()
        .foregroundColor(Color("PrimaryText"))
        .font(.title3)
        .background(Color("AccentText"))
        .cornerRadius(10)
    }
    
    var continueButton: some View {
        Button("Continue with the app") {
            openAttemptInfo.app.map {
                AppOpeningGuardService.shared.updateDidProceed(for: $0, with: Date.now)
            }
            if let url = openAttemptInfo.app?.url { openURL.callAsFunction(url) }
            presentationMode.wrappedValue.dismiss()
        }
        .foregroundColor(Color("PrimaryText"))
        .font(.title3)
    }
    
    var progressView: some View {
        ProgressView(value: breathingProgress, total: Constants.breathingTotalProgress)
            .progressViewStyle(
                GaugeProgressViewStyle(
                    strokeColor: Constants.progressViewColor.opacity(0.5)
                )
            )
            .frame(
                width: Constants.progressViewFrameSize,
                height: Constants.progressViewFrameSize
            )
    }
    
    var appInfo: some View {
        VStack(alignment: .center) {
            Text("\(openAttemptInfo.attemptsNumber ?? 0)")
                .font(.largeTitle.bold())
            Text(attemptsText(for: openAttemptInfo.attemptsNumber, app: openAttemptInfo.app))
                .font(.title2)
                .multilineTextAlignment(.center)
            Text(timeSpentText(for: openAttemptInfo.timeSpent ?? 0) ?? "")
                .font(.title3)
                .multilineTextAlignment(.center)
        }
        .padding()
        .isHidden(appInfoIsHidden, shouldBeRemoved: true)
    }
    
    private func titleView(text: String) -> some View {
        Text(text)
            .font(.title.bold())
            .foregroundColor(Color("AccentText"))
            .multilineTextAlignment(.center)
            .transition(.opacity)
    }
    
    private func timeSpentText(for time: TimeInterval) -> String? {
        guard !time.isLess(than: 1.0) else { return nil }
        let minutes = time / 60
        if minutes.isLess(than: 1) {
            return String(format: "spent %.f second(s) in the app", time)
        }
        if minutes.isLess(than: 60) {
            return String(format: "spent %.f minute(s) in the app", time / 60)
        }
        return String(
            format: "spent %.f hour(s) %.f minute(s) in the app",
            time / 360,
            time.truncatingRemainder(dividingBy: 360)
        )
    }
    
    private func startBreathAnimation() {
        var delay: TimeInterval = 0.5
        for _ in 0..<3 {
            animate(with: &delay, state: .firstBreath, delayDelta: 0.55)
            animate(with: &delay, state: .secondBreath, delayDelta: 0.55)
            animate(with: &delay, state: .exhale, delayDelta: 1.1)
        }
        notifyOfBreathingExerciseFinish(delay: delay)
        animate(with: &delay, state: .final, delayDelta: 2)
        animate(with: &delay, state: .stopped)
    }
    
    private func notifyOfBreathingExerciseFinish(delay: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            guard presentationMode.wrappedValue.isPresented else { return }
            HapticsService.shared.success()
        }
    }
    
    private func animate(
        with delay: inout TimeInterval,
        state: AnimationState,
        delayDelta: CGFloat? = nil
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation {
                animationState = state
                if breathingProgress <= Constants.breathingTotalProgress - Constants.breathingProgressStep {
                    breathingProgress += Constants.breathingProgressStep
                }
            }
        }
        delayDelta.map { delay += $0 }
    }
    
    private var appInfoIsHidden: Bool {
        openAttemptInfo.app == nil || openAttemptInfo.attemptsNumber == nil
    }
    
    private func attemptsText(for attempts: Int?, app: Application?) -> String {
        guard let attempts = attempts, let app = app else { return "" }
        return "attempt\(attempts == 1 ? "" : "s") to open \(app.name) today"
    }

    enum Constants {
        static let gradientStart = Color("Accent")
        static let gradientEnd = Color("Accent2")
        static let breathingProgressStep = 0.10
        static let breathingTotalProgress = 1.00
        static let progressViewFrameSize = 200.0
        static let progressViewColor = Color.white
    }
}

struct PopupView_Previews: PreviewProvider {
    static var previews: some View {
        PopupView(openAttemptInfo: .init(attemptsNumber: 5, app: .tiktok))
    }
}
