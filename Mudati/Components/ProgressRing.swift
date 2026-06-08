//
//  ProgressRing.swift
//  Mudati
//
//  Created by Alanoud Aljasser on 14/12/1447 AH.
//

import SwiftUI

struct ProgressRing: View {
    
    let percentage: Double
    
    private var progress: Double {
        min(percentage / 30, 1)
    }
    
    private var ringColor: Color {
        switch percentage {
        case 0..<10: return .green
        case 10..<20: return .orange
        default: return .red
        }
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(ringColor.opacity(0.15), lineWidth: 10)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    ringColor,
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.snappy, value: progress)
            
            Text("\(Int(percentage))%")
                .font(.subheadline)
        }
        .frame(width: 78, height: 78)
    }
}
