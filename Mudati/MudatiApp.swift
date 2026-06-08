//
//  MudatiApp.swift
//  Mudati
//
//  Created by Alanoud Aljasser on 13/12/1447 AH.
//

import SwiftUI
import SwiftData

@main
struct MudatiApp: App {

    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                HomeView()
                    .onAppear {
                        NotificationService.shared.requestPermission()
                    }
            } else {
                OnboardingView()
            }
        }
        .modelContainer(for: [Subscription.self, FixedCommitment.self])    }
}
