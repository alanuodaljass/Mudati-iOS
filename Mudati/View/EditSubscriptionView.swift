//
//  EditSubscriptionView..swift
//  Mudati
//
//  Created by Alanoud Aljasser on 14/12/1447 AH.
//

import SwiftUI
import SwiftData

struct EditSubscriptionView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @Bindable var subscription: Subscription

    @State private var iconColor: Color = .orange
    @State private var showDeleteConfirm = false

    private var calculatedEndDate: Date {
        Calendar.current.date(
            byAdding: .day,
            value: subscription.billingCycle.days,
            to: subscription.startDate
        ) ?? subscription.startDate
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {

                        mainCard

                        renewalCard

                        actionButtons

                        Text("عند تغيير تاريخ البداية أو الفوترة، سيتم تحديث تاريخ الانتهاء تلقائيًا.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 4)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 12)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("تعديل الاشتراك")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("إلغاء") { dismiss() }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("حفظ") { saveChanges() }
                        .fontWeight(.semibold)
                }
            }
            .onAppear {
                iconColor = Color(hex: subscription.iconColorHex)
            }
            .confirmationDialog(
                "حذف الاشتراك؟",
                isPresented: $showDeleteConfirm,
                titleVisibility: .visible
            ) {
                Button("حذف", role: .destructive) {
                    deleteSubscription()
                }

                Button("إلغاء", role: .cancel) {}
            } message: {
                Text("سيتم حذف الاشتراك نهائيًا من التطبيق.")
            }
        }
    }

    private var mainCard: some View {
        VStack(spacing: 0) {

            HStack(spacing: 14) {
                iconView

                TextField("اسم الاشتراك", text: $subscription.name)
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            .padding(.vertical, 18)

            Divider()

            row(title: "السعر") {
                HStack(spacing: 6) {
                    TextField("0", value: $subscription.price, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)

                    Text("ريال")
                        .foregroundStyle(.secondary)
                }
            }

            Divider()

            row(title: "الفوترة") {
                Picker("", selection: $subscription.billingCycle) {
                    ForEach(BillingCycle.allCases, id: \.self) { item in
                        Text(item.rawValue).tag(item)
                    }
                }
                .pickerStyle(.menu)
            }

            Divider()

            row(title: "تاريخ البداية") {
                DatePicker("", selection: $subscription.startDate, displayedComponents: .date)
                    .labelsHidden()
            }

            Divider()

            row(title: "ينتهي في") {
                Text(calculatedEndDate.formatted(date: .abbreviated, time: .omitted))
                    .foregroundStyle(.secondary)
            }

            if subscription.category == .other {
                Divider()

                row(title: "لون الأيقونة") {
                    ColorPicker("", selection: $iconColor)
                        .labelsHidden()
                        .onChange(of: iconColor) { _, newColor in
                            subscription.iconColorHex = newColor.toHex() ?? "#F2F2F7"
                        }
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("ملاحظات")
                    .foregroundStyle(.secondary)

                TextField("إضافة ملاحظة...", text: $subscription.notes, axis: .vertical)
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
            if subscription.category == .other {
                TextField("🏷️", text: $subscription.icon)
                    .font(.system(size: 30))
                    .multilineTextAlignment(.center)
                    .onChange(of: subscription.icon) { _, newValue in
                        if let first = newValue.first {
                            subscription.icon = String(first)
                        }
                    }
            } else {
                Image(systemName: subscription.icon)
                    .font(.system(size: 25, weight: .semibold))
            }
        }
        .frame(width: 64, height: 64)
        .background(subscription.category == .other ? iconColor.opacity(0.75) : Color(.systemGray6))
        .clipShape(Circle())
    }

    private var renewalCard: some View {
        VStack(spacing: 0) {
            Toggle("سحب تلقائي", isOn: $subscription.autoRenew)
                .padding(.vertical, 10)

            Divider()

            Toggle("أرغب بالاستمرار", isOn: $subscription.willRenew)
                .padding(.vertical, 10)
        }
        .padding(.horizontal, 18)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button {
                subscription.isArchived.toggle()
                saveChanges()
            } label: {
                Label(
                    subscription.isArchived ? "إرجاع" : "أرشفة",
                    systemImage: subscription.isArchived ? "arrow.uturn.backward.circle.fill" : "archivebox.fill"
                )
                .frame(maxWidth: .infinity)
            }
            .foregroundStyle(.secondary)
            .background(.thinMaterial)
            Button(role: .destructive) {
                showDeleteConfirm = true
            } label: {
                Label("حذف", systemImage: "trash.fill")
                   
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
        }
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

    private func saveChanges() {
        subscription.endDate = calculatedEndDate
        subscription.iconColorHex = iconColor.toHex() ?? subscription.iconColorHex

        do {
            try context.save()
            Task {
                await SupabaseManager.shared.updateSubscription(subscription)
            }
            NotificationService.shared.scheduleRenewalReminders(for: subscription)
            dismiss()
        } catch {
            print("Edit save error:", error.localizedDescription)
        }
   
    }

    private func deleteSubscription() {
        let cloudId = subscription.cloudId

        context.delete(subscription)

        do {
            try context.save()

            Task {
                await SupabaseManager.shared.deleteSubscriptionByCloudId(cloudId)
            }

            dismiss()

        } catch {
            print("Delete error:", error.localizedDescription)
        }
    }
}
