//
//  SubscriptionPreset.swift
//  Mudati
//
//  Created by Alanoud Aljasser on 14/12/1447 AH.
//

import Foundation

struct SubscriptionPreset: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let icon: String
    let category: SubscriptionCategory
    
    static let all: [SubscriptionPreset] = [
        .init(name: "لياقة", icon: "figure.run", category: .fitness),
        .init(name: "ترفية", icon: "play.tv.fill", category: .entertainment),
//        .init(name: "Shahid", icon: "play.rectangle.fill", category: .entertainment),
        .init(name: "وجبات", icon: "fork.knife", category: .food),
        .init(name: "تنظيف", icon: "sparkles", category: .cleaning),
        .init(name: "تأمين", icon: "shield.fill", category: .insurance),
        .init(name: "اخرى", icon: "plus.circle", category: .other)
    ]
}
