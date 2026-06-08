//
//  Subscription.swift
//  Mudati
//
//  Created by Alanoud Aljasser on 13/12/1447 AH.
//
import Foundation
import SwiftData
import SwiftUI

enum SubscriptionCategory: String, Codable, CaseIterable {
    case entertainment = "ترفيه"
    case fitness = "لياقة"
    case apps = "تطبيقات"
    case insurance = "تأمين"
    case food = "وجبات"
    case cleaning = "تنظيف"
    case other = "أخرى"

    var icon: String {
        switch self {
        case .entertainment: return "tv"
        case .fitness: return "figure.run"
        case .apps: return "apps.iphone"
        case .insurance: return "shield"
        case .food: return "fork.knife"
        case .cleaning: return "sparkles"
        case .other: return "tag"
        }
    }
}

enum BillingCycle: String, Codable, CaseIterable {
    case weekly = "أسبوع"
    case monthly = "شهر"
    case twoMonths = "شهرين"
    case threeMonths = "3 شهور"
    case sixMonths = "6 شهور"
    case yearly = "سنة"

    var days: Int {
        switch self {

        case .weekly:
            return 7

        case .monthly:
            return 30

        case .twoMonths:
            return 60

        case .threeMonths:
            return 90

        case .sixMonths:
            return 180

        case .yearly:
            return 365
        }
    }
}

@Model
final class Subscription {
    var name: String
    var price: Double
    var category: SubscriptionCategory
    var billingCycle: BillingCycle
    var startDate: Date
    var endDate: Date
    var autoRenew: Bool
    var willRenew: Bool
    var icon: String
    var isArchived: Bool
    var notes: String
    var iconColorHex: String
    var cloudId: String
    
    init(
        icon: String,
        name: String,
        price: Double,
        category: SubscriptionCategory,
        billingCycle: BillingCycle,
        startDate: Date,
        endDate: Date,
        autoRenew: Bool,
        willRenew: Bool,
        isArchived: Bool = false,
        notes: String = "",
        iconColorHex: String = "#F2F2F7" ,
        cloudId: String = UUID().uuidString
    ) {
        self.name = name
        self.price = price
        self.category = category
        self.billingCycle = billingCycle
        self.startDate = startDate
        self.endDate = endDate
        self.autoRenew = autoRenew
        self.willRenew = willRenew
        self.icon = icon
        self.isArchived = isArchived
        self.notes = notes
        self.iconColorHex = iconColorHex
        self.cloudId = cloudId
    }
    
    var daysLeft: Int {
        max(0, Calendar.current.dateComponents([.day], from: .now, to: endDate).day ?? 0)
    }
    
    var monthlyPrice: Double {
        switch billingCycle {
        case .weekly:
            return price * 4.33
            
        case .monthly:
            return price
      
        case.twoMonths:
            return price / 2
            
        case .threeMonths:
            return price / 3
          
            
        case .sixMonths:
            return price / 6
            
        case .yearly:
            return price / 12
        }
    }
    var isExpired: Bool {
        endDate < Date()
    }
    var statusColor: Color {

        switch category {
            
        case .entertainment:
            return .green
            
        case .fitness:
            return .blue
            
        case .food:
            return .orange
            
        case .apps:
            return .purple
            
        case .insurance:
            return .red
            
        case .cleaning:
            return .cyan
            
        case .other:
            return .gray
            
            
            
        }
    }

    var cardColor: Color {
        if isArchived || isExpired {
            return Color.gray.opacity(0.14)
        }
        
        switch category {
        case .entertainment:
            return Color.green.opacity(0.12)
        case .fitness:
            return Color.blue.opacity(0.12)
        case .food:
            return Color.orange.opacity(0.13)
        case .apps:
            return Color.purple.opacity(0.12)
        case .insurance:
            return Color.red.opacity(0.10)
        case .cleaning:
            return Color.cyan.opacity(0.12)
        case .other:
            return Color.gray.opacity(0.12)
        }
    }
    var arabicEndDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ar")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: endDate)
    }

    var arabicStartDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ar")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: startDate)
    }
    var quickInsight: String {

        if isExpired {
            return "منتهي"
        }

        if daysLeft <= 7 {
            return "ينتهي قريبًا"
        }

        if autoRenew {
            return "سحب تلقائي"
        }

        if billingCycle == .yearly {
            return "اشتراك سنوي"
        }

        if billingCycle == .sixMonths {
            return "اشتراك نصف سنوي"
        }

        return "نشط"
    }

}
extension Color {
    func toHex() -> String? {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        guard uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }

        return String(
            format: "#%02X%02X%02X",
            Int(red * 255),
            Int(green * 255),
            Int(blue * 255)
        )
    }
}

extension Color {

    init(hex: String) {

        let hex = hex.trimmingCharacters(
            in: CharacterSet.alphanumerics.inverted
        )

        var int: UInt64 = 0

        Scanner(string: hex).scanHexInt64(&int)

        let r, g, b: UInt64

        switch hex.count {

        case 6:
            (r, g, b) = (
                (int >> 16) & 0xFF,
                (int >> 8) & 0xFF,
                int & 0xFF
            )

        default:
            (r, g, b) = (0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1
        )
    }
}
