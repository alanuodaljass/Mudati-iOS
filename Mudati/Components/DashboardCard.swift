//
//  DashboardCard.swift
//  Mudati
//
//  Created by Alanoud Aljasser on 15/12/1447 AH.
//
import SwiftUI

struct DashboardCard: View {
    
    let subscriptions: [Subscription]
    @Binding var monthlyIncome: Double
    let commitments: [FixedCommitment]
    
    @State private var showIncomeSheet = false
    @State private var incomeText = ""
    
    private var active: [Subscription] {
        subscriptions.filter { !$0.isArchived && !$0.isExpired }
    }
    
    private var expired: [Subscription] {
        subscriptions.filter { $0.isExpired }
    }
    
    private var archived: [Subscription] {
        subscriptions.filter { $0.isArchived }
    }
    
    private var subscriptionsTotal: Double {
        active.reduce(0) { $0 + $1.monthlyPrice }
    }
    
    private var commitmentsTotal: Double {
        commitments.reduce(0) { $0 + $1.amount }
    }
    
    private var totalObligations: Double {
        subscriptionsTotal + commitmentsTotal
    }
    
    private var remainingIncome: Double {
        max(monthlyIncome - totalObligations, 0)
    }
    
    private var percentage: Int {
        guard monthlyIncome > 0 else { return 0 }
        return Int(round((totalObligations / monthlyIncome) * 100))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            HStack(alignment: .center, spacing: 18) {
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(monthlyIncome <= 0 ? "أضف دخلك الشهري" : "إجمالي التزاماتك")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(monthlyIncome <= 0 ? "احسب نسبتك" : "\(Int(totalObligations)) ريال")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    
                    Text(monthlyIncome <= 0
                         ? "اضغطي على الدائرة وسجّلي دخلك."
                         : "\(percentage)% من دخلك الشهري")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button {
                    showIncomeSheet = true
                    incomeText = monthlyIncome > 0 ? "\(Int(monthlyIncome))" : ""
                } label: {
                    ZStack {
                        Circle()
                            .stroke(.green.opacity(monthlyIncome <= 0 ? 0.18 : 0.28), lineWidth: 13)
                            .frame(width: 105, height: 105)
                        
                        if monthlyIncome <= 0 {
                            Image(systemName: "plus")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundStyle(.secondary)
                        } else {
                            Text("\(percentage)%")
                                .font(.system(size: 27, weight: .bold, design: .rounded))
                        }
                    }
                }
                .buttonStyle(.plain)
            }
            
            if monthlyIncome > 0 {
                VStack(spacing: 10) {
                    HStack(spacing: 10) {
                        amountBox(title: "اشتراكات", value: subscriptionsTotal)
                        amountBox(title: "ثابتة", value: commitmentsTotal)
                        amountBox(title: "المتبقي", value: remainingIncome)
                    }
                    
                    Text("الدخل الشهري: \(Int(monthlyIncome)) ريال")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            
            Divider().opacity(0.35)
            
//            HStack(spacing: 10) {
//                statBox(title: "نشطة", value: "\(active.count)")
//                statBox(title: "منتهية", value: "\(expired.count)")
//                statBox(title: "مؤرشفة", value: "\(archived.count)")
//            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 14, x: 0, y: 6)
        .sheet(isPresented: $showIncomeSheet) {
            incomeSheet
                .presentationDetents([.height(280)])
        }
    }
    
    private func amountBox(title: String, value: Double) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            
            Text("\(Int(value)) ريال")
                .font(.subheadline)
                .fontWeight(.bold)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.55))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
    
//    private func statBox(title: String, value: String) -> some View {
//        VStack(alignment: .leading, spacing: 4) {
//            Text(title)
//                .font(.caption2)
//                .foregroundStyle(.secondary)
//            
//            Text(value)
//                .font(.headline)
//        }
//        .padding(12)
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .background(.white.opacity(0.45))
//        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
//    }
    
    private var incomeSheet: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("الدخل الشهري")
                .font(.title2.bold())
            
            Text("نستخدمه لحساب نسبة الاشتراكات والالتزامات من دخلك.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            TextField("مثال: 8500", text: $incomeText)
                .keyboardType(.decimalPad)
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            
            Button {
                let clean = cleanNumber(incomeText)
                if let value = Double(clean), value > 0 {
                    monthlyIncome = value
                    showIncomeSheet = false
                }
            } label: {
                Text("حفظ")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
        }
        .padding(22)
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
