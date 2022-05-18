//
//  IntentHandler.swift
//  MiqiShortcutIntent
//
//  Created by Elena Gordienko on 26.03.2022.
//

import Intents

final class IntentHandler: INExtension {
    override func handler(for intent: INIntent) -> Any {
        if intent is OpenAppIntent {
            return OpenAppIntentHandler()
        }
        if intent is CloseAppIntent {
            return CloseAppIntentHandler()
        }
        fatalError("Unknown intent type: \(intent)")
    }
}
