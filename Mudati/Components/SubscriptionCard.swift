//
//  SubscriptionCard.swift
//  Mudati
//
//  Created by Alanoud Aljasser on 13/12/1447 AH.
//


import SwiftUI

struct SubscriptionCard: View {


let subscription: Subscription

var body: some View {

    HStack(spacing: 14) {

        Rectangle()
            .fill(subscription.statusColor)
            .frame(width: 5)
            .clipShape(Capsule())

        Image(systemName: subscription.icon)
            .font(.system(size: 18, weight: .semibold))
            .frame(width: 46, height: 46)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))

        VStack(alignment: .leading, spacing: 8) {

            Text(subscription.name)
                .font(.headline)

            Text(subscription.category.rawValue)
                .font(.caption)
                .foregroundStyle(.secondary)

            statusBadge
        }

        Spacer()

        VStack(alignment: .trailing, spacing: 6) {

            Text("\(subscription.price, specifier: "%.0f") ﷼")
                .font(.headline)

            Text("يعادل \(subscription.monthlyPrice, specifier: "%.0f") ﷼ شهريًا")
                .font(.caption2)
                .foregroundStyle(.secondary)

            Text(
                subscription.isExpired
                ? "منتهي"
                : "باقي \(subscription.daysLeft) يوم"
            )
            .font(.caption)
            .foregroundStyle(daysColor)
        }
    }
    .padding(16)
    .background(subscription.cardColor)
    .clipShape(RoundedRectangle(cornerRadius: 24))
    .shadow(
        color: .black.opacity(0.04),
        radius: 12,
        x: 0,
        y: 6
    )
}

@ViewBuilder
private var statusBadge: some View {

    if subscription.isArchived {

        badge(
            "سابق",
            icon: "archivebox.fill",
            color: .gray
        )

    } else if subscription.isExpired {

        badge(
            "منتهي",
            icon: "clock.badge.xmark.fill",
            color: .gray
        )

    } else if subscription.autoRenew {

        badge(
            "سحب تلقائي",
            icon: "arrow.triangle.2.circlepath",
            color: .green
        )

    } else if subscription.willRenew {

        badge(
            "مستمر",
            icon: "checkmark.circle.fill",
            color: .blue
        )

    } else {

        badge(
            "غير مؤكد",
            icon: "questionmark.circle.fill",
            color: .orange
        )
    }
}

private func badge(
    _ text: String,
    icon: String,
    color: Color
) -> some View {

    HStack(spacing: 4) {

        Image(systemName: icon)

        Text(text)
    }
    .font(.caption2)
    .foregroundStyle(color)
    .padding(.horizontal, 8)
    .padding(.vertical, 4)
    .background(color.opacity(0.12))
    .clipShape(Capsule())
}

private var daysColor: Color {

    switch subscription.daysLeft {

    case 0...3:
        return .red

    case 4...7:
        return .orange

    default:
        return .secondary
    }
}

}
