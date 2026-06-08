//
//  OnboardingView.swift
//  Mudati
//
//  Created by Alanoud Aljasser on 17/12/1447 AH.
//

import SwiftUI

struct OnboardingView: View {

    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color(.secondarySystemGroupedBackground))
                    .frame(width: 120, height: 120)

                Image("onbordingicon")
                    .resizable()
                       .scaledToFit()
                       .frame(width: 80, height: 80)
                       .cornerRadius(12)
                 
            }

            VStack(spacing: 10) {
                Text("مُدّتي")
                    .font(.system(size: 42, weight: .bold, design: .rounded))

                Text("كل اشتراكاتك، بمكان واحد")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 12) {
                featureRow(icon: "bell.badge",   title: "نبهني قبل ما يتجدد")
                featureRow(icon: "chart.pie",    title: "كم تصرف على اشتراكاتك")
                featureRow(icon: "archivebox",   title: "احتفظ بسجل اشتراكاتك")
            }
            .padding(.top, 8)

            Spacer()

            Button {
                hasSeenOnboarding = true
            } label: {
                Text("ابدأ الآن")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.black)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
        .padding(24)
        .background(Color(.systemGroupedBackground))
    }

    private func featureRow(icon: String, title: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .frame(width: 38, height: 38)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(Circle())

            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)

            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
