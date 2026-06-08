//
//  FixedCommitment.swift
//  Mudati
//
//  Created by Alanoud Aljasser on 20/12/1447 AH.
//

import Foundation
import SwiftData

@Model
final class FixedCommitment {
    
    var name: String
    var amount: Double
    var icon: String
    var createdAt: Date
    var cloudId: String
    
    init(
        name: String,
        amount: Double,
        icon: String = "pin.fill",
        createdAt: Date = Date(),
        cloudId: String = UUID().uuidString
    ) {
        self.name = name
        self.amount = amount
        self.icon = icon
        self.createdAt = createdAt
        self.cloudId = cloudId
    }
}
