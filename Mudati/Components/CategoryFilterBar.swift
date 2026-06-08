//
//  CategoryFilterBar.swift
//  Mudati
//
//  Created by Alanoud Aljasser on 14/12/1447 AH.
//

import SwiftUI

struct CategoryFilterBar: View {
    
    @Binding var selectedCategory: SubscriptionCategory?
    let subscriptions: [Subscription]
    
    private var usedCategories: [SubscriptionCategory] {
        SubscriptionCategory.allCases.filter { category in
            subscriptions.contains { $0.category == category }
        }
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                
                categoryButton(
                    title: "الكل",
                    icon: "square.grid.2x2.fill",
                    category: nil,
                    count: subscriptions.count
                )
                
                ForEach(usedCategories, id: \.self) { category in
                    categoryButton(
                        title: category.rawValue,
                        icon: category.icon,
                        category: category,
                        count: subscriptions.filter { $0.category == category }.count
                    )
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    private func categoryButton(
        title: String,
        icon: String,
        category: SubscriptionCategory?,
        count: Int
    ) -> some View {
        
        let isSelected = selectedCategory == category
        
        return Button {
            withAnimation(.snappy) {
                selectedCategory = category
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                
                Text(title)
                
                Text("\(count)")
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        isSelected
                        ? Color.black.opacity(0.08)
                        : Color.primary.opacity(0.08)
                    )                    .clipShape(Capsule())
            }
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 13)
            .padding(.vertical, 10)
            .background(
                isSelected
                ? Color.white
                : Color(UIColor.secondarySystemBackground)
            )
            .foregroundStyle(
                isSelected
                ? Color.black
                : Color.primary
            )
            .clipShape(Capsule())
            .shadow(color: .black.opacity(isSelected ? 0.10 : 0.03), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}
