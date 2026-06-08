//
//  HomeView.swift
//  Mudati
//
//  Created by Alanoud Aljasser on 13/12/1447 AH.
//

import SwiftUI
import SwiftData

struct HomeView: View {
//    @EnvironmentObject var authManager: AuthManager
    @Environment(\.modelContext) private var context
    @Query(sort: \Subscription.endDate) private var subscriptions: [Subscription]
//    @State private var searchText = ""
    @State private var showAdd = false
    @State private var showSettings = false
    @State private var selectedSubscription: Subscription?
    @State private var selectedCategory: SubscriptionCategory? = nil
    @State private var showIncomeSheet = false
    @State private var showAddSheet = false
    @AppStorage("monthlyIncome") private var monthlyIncome: Double = 0
    @Query(sort: \FixedCommitment.createdAt) private var commitments: [FixedCommitment]
    var totalMonthly: Double {
        subscriptions
            .filter { !$0.isArchived }
            .reduce(0) { $0 + $1.monthlyPrice }
    }
    
    var filteredSubscriptions: [Subscription] {
        guard let selectedCategory else { return subscriptions }
        return subscriptions.filter { $0.category == selectedCategory }
    }
    
    var activeSubscriptions: [Subscription] {
        filteredSubscriptions.filter { !$0.isArchived }
    }
    
    var archivedSubscriptions: [Subscription] {
        filteredSubscriptions.filter { $0.isArchived }
    }
    
    var incomePercentage: Double {
        guard monthlyIncome > 0 else { return 0 }
        return (totalMonthly / monthlyIncome) * 100
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                     
                        header

                        DashboardCard(
                            subscriptions: subscriptions,
                            monthlyIncome: $monthlyIncome,
                            commitments: commitments
                        )
                      
                    
//                        SmartInsightCard(
//                            subscriptions: subscriptions,
//                            totalMonthly: totalMonthly ,monthlyIncome: monthlyIncome
//                        )

                        CategoryFilterBar(
                            selectedCategory: $selectedCategory,
                            subscriptions: subscriptions
                        )
                        
                        sectionTitle
                        
                        if activeSubscriptions.isEmpty && archivedSubscriptions.isEmpty {
                            emptyState
              
                        } else {
                            VStack(spacing: 12) {
                                ForEach(activeSubscriptions) { sub in
                                    Button {
                                        selectedSubscription = sub
                                    } label: {
                                        SubscriptionCard(subscription: sub)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            
                            if !archivedSubscriptions.isEmpty {
                                Text("اشتراكاتك السابقة")
                                    .font(.headline)
                                    .padding(.top, 12)
                                
                                VStack(spacing: 12) {
                                    ForEach(archivedSubscriptions) { sub in
                                        Button {
                                            selectedSubscription = sub
                                        } label: {
                                            SubscriptionCard(subscription: sub)
                                                .opacity(0.7)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 12)
                    .padding(.bottom, 32)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showAdd) {
                AddSubscriptionView()
            }
            .sheet(isPresented: $showSettings) {
                FinancialSettingsView()
            }
            .sheet(item: $selectedSubscription) { subscription in
                NavigationStack {
                    SubscriptionDetailsView(subscription: subscription)
                }
            }
            .animation(.snappy, value: subscriptions.count)
        }.onAppear {
            restoreFromSupabase()
        }
    }
    
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("مُدّتي")
                    .font(.system(size: 25, weight: .bold, design: .rounded))
                
                Text("كل اشتراكاتك، بمكان واحد")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 10) {
                CircleButton(systemName: "gearshape.fill") {
                    showSettings = true
                }
                
                CircleButton(systemName: "plus") {
                    showAdd = true
                }
            }
        }
        .padding(.top, 8)
    }
    private func restoreFromSupabase() {
        Task {
            let cloudItems = await SupabaseManager.shared.fetchSubscriptions()
            
            for item in cloudItems {
                let exists = subscriptions.contains {
                    $0.cloudId == item.cloud_id
                }
                
                if !exists {
                    let start = dateFromString(item.start_date)
                    let end = dateFromString(item.end_date)
                    
                    let sub = Subscription(
                        icon: item.icon,
                        name: item.name,
                        price: item.price,
                        category: SubscriptionCategory(rawValue: item.category) ?? .other,
                        billingCycle: BillingCycle(rawValue: item.billing_cycle) ?? .monthly,
                        startDate: start,
                        endDate: end,
                        autoRenew: item.auto_renew,
                        willRenew: item.will_renew,
                        isArchived: item.is_archived,
                        notes: item.notes,
                        iconColorHex: item.icon_color_hex,
                        cloudId: item.cloud_id
                    )
                    
                    context.insert(sub)
                }
            }
            
            do {
                try context.save()
                print("✅ Restored to SwiftData")
            } catch {
                print("❌ Restore save error:", error.localizedDescription)
            }
        }
    }
    
    private func dateFromString(_ text: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: text) ?? Date()
    }
    private var sectionTitle: some View {
        HStack {
            Text("اشتراكاتك")
                .font(.headline)
            
            Spacer()
            
            Text("\(activeSubscriptions.count)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(.thinMaterial)
                .clipShape(Capsule())
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "rectangle.stack.badge.plus")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
            
            Text("ما عندك اشتراكات بعد")
                .font(.headline)
            
            Text("اضغط + وأضيف أول اشتراك")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 70)
    }
}

#Preview {
HomeView()
}
