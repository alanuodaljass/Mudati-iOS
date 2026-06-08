//
//  SubscriptionDetailsView.swift
//  Mudati
//
//  Created by Alanoud Aljasser on 14/12/1447 AH.
//

import SwiftUI
import SwiftData

struct SubscriptionDetailsView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @Bindable var subscription: Subscription
    @State private var showEdit = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                
                Image(systemName: subscription.icon)
                    .font(.system(size: 38, weight: .semibold))
                    .frame(width: 86, height: 86)
                    .background(subscription.cardColor)
                    .clipShape(Circle())
                
                VStack(spacing: 6) {
                    Text(subscription.name)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                    
                    Text(subscription.category.rawValue)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                detailsCard
                
                statusCard
                
                Button {
                    showEdit = true
                } label: {
                    Label("تعديل", systemImage: "square.and.pencil")
                        .font(.subheadline.weight(.medium))
                          .foregroundStyle(.primary)
                          .padding(.horizontal, 16)
                          .padding(.vertical, 10)
                          .background(.thinMaterial)
                          .clipShape(Capsule())
                }
//                .buttonStyle(.borderedProminent)
                
//                Button {
//                    subscription.isArchived.toggle()
//                    try? context.save()
//                    dismiss()
//                } label: {
////                    Label(
////                        subscription.isArchived ? "استرجاع للاشتراكات الحالية" : "لا ترغب في هذا الاشتراك؟   ",
////                        systemImage: subscription.isArchived ? "arrow.uturn.backward.circle.fill" : "archivebox.fill"
////                    )
////                    .frame(maxWidth: .infinity)
//                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
        .navigationTitle("التفاصيل")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showEdit) {
            EditSubscriptionView(subscription: subscription)
        }
    }
    
    private var detailsCard: some View {
        VStack(spacing: 14) {
            detailRow("السعر", "\(Int(subscription.price)) ريال")
              Divider()

              detailRow("الفوترة", subscription.billingCycle.rawValue)
              Divider()

              detailRow("تاريخ البداية", subscription.arabicStartDate)
              Divider()

              detailRow("تاريخ النهاية", subscription.arabicEndDate)
              Divider()

            detailRow(
"المتبقي",
                  subscription.isExpired ? "منتهي" : "\(subscription.daysLeft) يوم"
    )
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
    
    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("الحالة")
                .font(.headline)
            
            Text(subscription.quickInsight)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 8) {
                Circle()
                    .fill(subscription.statusColor)
                    .frame(width: 8, height: 8)
                
                Text(subscription.isArchived ? "ضمن الاشتراكات السابقة" : "ضمن الاشتراكات الحالية")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
    
    private func detailRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
        .font(.subheadline)
    }
}
