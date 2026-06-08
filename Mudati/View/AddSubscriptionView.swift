//
//  AddSubscriptionView.swift
//  Mudati
//
//  Created by Alanoud Aljasser on 13/12/1447 AH.
//

import SwiftUI
import SwiftData

struct AddSubscriptionView: View {

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var price = ""
    @State private var category: SubscriptionCategory = .entertainment
    @State private var billingCycle: BillingCycle = .monthly
    @State private var startDate = Date()
    @State private var autoRenew = true
    @State private var willRenew = false
    @State private var notes = ""

    @State private var selectedIcon = "tv"
    @State private var iconColor = Color(.systemGray6)

    private var calculatedEndDate: Date {
        Calendar.current.date(
            byAdding: .day,
            value: billingCycle.days,
            to: startDate
        ) ?? startDate
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {

                        categoryPicker

                        mainCard

                        renewalCard

                        saveHint
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 12)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("اشتراك جديد")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("إلغاء") { dismiss() }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("حفظ") { saveSubscription() }
                        .fontWeight(.semibold)
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || price.isEmpty)
                }
            }
            .onChange(of: category) { _, newValue in
                if newValue == .other {
                    selectedIcon = "🏷️"
                    iconColor = .orange
                    name = ""
                } else {
                    selectedIcon = newValue.icon
                    iconColor = Color(.systemGray6)
                }
            }
        }
    }

    private var categoryPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("التصنيف")
                .font(.headline)
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(SubscriptionCategory.allCases, id: \.self) { item in
                        Button {
                            category = item
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: item.icon)
                                Text(item.rawValue)
                            }
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(category == item ? .black : Color(.secondarySystemGroupedBackground))
                            .foregroundStyle(category == item ? .white : .primary)
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    private var mainCard: some View {
        VStack(spacing: 0) {

            HStack(spacing: 14) {
                iconView

                TextField("اسم الاشتراك", text: $name)
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            .padding(.vertical, 18)

            Divider()

            row(title: "السعر") {
                HStack(spacing: 6) {
                    TextField("0", text: $price)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)

                    Text("ريال")
                        .foregroundStyle(.secondary)
                }
            }

            Divider()

            row(title: "الفوترة") {
                Picker("", selection: $billingCycle) {
                    ForEach(BillingCycle.allCases, id: \.self) { item in
                        Text(item.rawValue).tag(item)
                    }
                }
                .pickerStyle(.menu)
            }

            Divider()

            row(title: "تاريخ البداية") {
                DatePicker("", selection: $startDate, displayedComponents: .date)
                    .labelsHidden()
            }

            Divider()

            row(title: "ينتهي في") {
                Text(calculatedEndDate.formatted(date: .abbreviated, time: .omitted))
                    .foregroundStyle(.secondary)
            }

            if category == .other {
                Divider()

                row(title: "لون الأيقونة") {
                    ColorPicker("", selection: $iconColor)
                        .labelsHidden()
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("ملاحظات")
                    .foregroundStyle(.secondary)

                TextField("إضافة ملاحظة...", text: $notes, axis: .vertical)
                    .lineLimit(3...5)
            }
            .padding(.vertical, 14)
        }
        .padding(.horizontal, 18)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private var iconView: some View {
        Group {
            if category == .other {
                TextField("🏷️", text: $selectedIcon)
                    .font(.system(size: 30))
                    .multilineTextAlignment(.center)
                    .onChange(of: selectedIcon) { _, newValue in
                        if let first = newValue.first {
                            selectedIcon = String(first)
                        }
                    }
            } else {
                Image(systemName: selectedIcon)
                    .font(.system(size: 25, weight: .semibold))
            }
        }
        .frame(width: 64, height: 64)
        .background(category == .other ? iconColor.opacity(0.75) : Color(.systemGray6))
        .clipShape(Circle())
    }

    private var renewalCard: some View {
        VStack(spacing: 0) {
            Toggle("سحب تلقائي", isOn: $autoRenew)
                .padding(.vertical, 10)

            Divider()

            Toggle("أرغب بالاستمرار", isOn: $willRenew)
                .padding(.vertical, 10)
        }
        .padding(.horizontal, 18)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var saveHint: some View {
        Text("سيتم حساب تاريخ الانتهاء تلقائيًا بناءً على تاريخ البداية والفوترة.")
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 4)
    }

    private func row<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)

            Spacer()

            content()
        }
        .padding(.vertical, 14)
    }

    private func saveSubscription() {
        let cleanPrice = cleanNumber(price)

        guard let priceValue = Double(cleanPrice) else {
            print("السعر غلط:", price)
            return
        }

        let subscription = Subscription(
            icon: selectedIcon,
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            price: priceValue,
            category: category,
            billingCycle: billingCycle,
            startDate: startDate,
            endDate: calculatedEndDate,
            autoRenew: autoRenew,
            willRenew: willRenew,
            notes: notes,
            iconColorHex: iconColor.toHex() ?? "#F2F2F7"
        )

        context.insert(subscription)

        do {
            try context.save()

            NotificationService.shared.scheduleRenewalReminders(for: subscription)

            Task {
                await SupabaseManager.shared.uploadSubscription(subscription)
            
            }

            dismiss()
        } catch {
            print("Save error:", error.localizedDescription)
        }
    }

    private func cleanNumber(_ text: String) -> String {
        text
            .replacingOccurrences(of: "٫", with: ".")
            .replacingOccurrences(of: ",", with: ".")
            .replacingOccurrences(of: "٠", with: "0")
            .replacingOccurrences(of: "١", with: "1")
            .replacingOccurrences(of: "٢", with: "2")
            .replacingOccurrences(of: "٣", with: "3")
            .replacingOccurrences(of: "٤", with: "4")
            .replacingOccurrences(of: "٥", with: "5")
            .replacingOccurrences(of: "٦", with: "6")
            .replacingOccurrences(of: "٧", with: "7")
            .replacingOccurrences(of: "٨", with: "8")
            .replacingOccurrences(of: "٩", with: "9")
    }
}
