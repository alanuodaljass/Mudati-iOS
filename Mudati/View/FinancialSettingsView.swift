//
//  FinancialSettingsView.swift
//  Mudati
//
//  Created by Alanoud Aljasser on 13/12/1447 AH.
//

import SwiftUI
import SwiftData
struct FinancialSettingsView: View {
    
    @Environment(\.dismiss) private var dismiss
    //    @EnvironmentObject var authManager: AuthManager
    @Environment(\.modelContext) private var context
    @Query(sort: \FixedCommitment.createdAt) private var commitments: [FixedCommitment]
    
    @State private var commitmentName = ""
    @State private var commitmentAmount = ""
    //    @State private var showLogin = false
    @AppStorage("monthlyIncome") private var monthlyIncome: Double = 0
    @State private var incomeText = ""
    
    var body: some View {
        NavigationStack {
            ScrollView{
                ZStack {
                    
                    Color(.systemGroupedBackground)
                        .ignoresSafeArea()
                    
                    VStack(alignment: .leading, spacing: 22) {
                        
                        HStack {
                            Button("إلغاء") {
                                dismiss()
                            }
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                            
                            Spacer()
                            
                            Button("حفظ") {
                                monthlyIncome = Double(cleanNumber(incomeText)) ?? 0
                                dismiss()
                            }
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                        }
                        
                        Text("الإعدادات")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                        
                        incomeCard
                        
                        commitmentsCard
                        
                        aboutCard
                        
                        Spacer()
                    }
                    .padding(22)
                }
                .onAppear {
                    if monthlyIncome > 0 {
                        incomeText = String(format: "%.0f", monthlyIncome)
                    }
                }
                //            .sheet(isPresented: $showLogin) {
                ////                LoginView()
                ////                    .environmentObject(authManager)
                //            }
            }
        }
    }
    private var incomeCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("الدخل الشهري")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            TextField("مثال:  ريال 5000", text: $incomeText)
                .keyboardType(.decimalPad)
                .font(.title3)
                .padding()
                .background(fieldBackground)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            
            Text("نستخدم الدخل فقط لحساب نسبة الاشتراكات من دخلك الشهري.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
    
    private var commitmentsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("التزاماتك الثابتة")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Text("أضيف الالتزامات الشهرية مثل الإيجار أو القسط ليحسبها مُدّتي مع الاشتراكات.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            VStack(spacing: 10) {
                TextField("اسم الالتزام: إيجار، قسط سيارة...", text: $commitmentName)
                    .padding()
                    .background(fieldBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                
                TextField("المبلغ الشهري", text: $commitmentAmount)
                    .keyboardType(.decimalPad)
                    .padding()
                    .background(fieldBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                
                Button {
                    addCommitment()
                } label: {
                    Label("إضافة التزام", systemImage: "plus")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .background(.black)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            
            if !commitments.isEmpty {
                Divider()
                
                ForEach(commitments) { item in
                    HStack {
                        Image(systemName: item.icon)
                            .frame(width: 34, height: 34)
                            .background(.thinMaterial)
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text(item.name)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            Text("\(Int(item.amount)) ريال شهريًا")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(role: .destructive) {
                            deleteCommitment(item)
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
    
    private var aboutCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            HStack(spacing: 14) {
                Image("DeveloperMemoji")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 56, height: 56)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("طُوّر بواسطة")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text("Alanoud Aljasser")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text("Mudati • الإصدار 1.1")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            
            Divider()
            
            Link(destination: URL(string: "https://www.linkedin.com/in/alanoud-al-jasser-b14233260")!) {
                Label("LinkedIn", systemImage: "link")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            
            Link(destination: URL(string: "https://towering-pan-4a9.notion.site/Privacy-Policy-for-Mudati-3746cdd2643780b18db2c9708b4f8263")!) {
                Label("سياسة الخصوصية", systemImage: "shield")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
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
    private func addCommitment() {
        let clean = cleanNumber(commitmentAmount)
        
        guard
            !commitmentName.trimmingCharacters(in: .whitespaces).isEmpty,
            let amount = Double(clean),
            amount > 0
        else { return }
        
        let item = FixedCommitment(
            name: commitmentName,
            amount: amount
        )
        
        context.insert(item)
        try? context.save()
        
        commitmentName = ""
        commitmentAmount = ""
    }
    
    private func deleteCommitment(_ item: FixedCommitment) {
        context.delete(item)
        try? context.save()
    }
 
    private var cardBackground: Color {
        Color(.secondarySystemGroupedBackground)
    }

    private var fieldBackground: Color {
        Color(.systemBackground)
    }
}
