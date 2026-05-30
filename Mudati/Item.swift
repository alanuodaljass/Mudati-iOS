//
//  Item.swift
//  Mudati
//
//  Created by Alanoud Aljasser on 13/12/1447 AH.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
