//
//  DailyProgressView.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/30.
//

import SwiftUI
import WidgetKit

struct ProgressBarView: View {
    var progress: Double
    var remainingValue: Int
    var basicGoal: Int
    
    var body: some View {
        GeometryReader { geometry in
            let diameter = min(geometry.size.width, geometry.size.height)
            let lineWidth = diameter * 0.1
            
            ZStack {
                Circle()
                    .stroke(lineWidth: lineWidth)
                    .opacity(0.3)
                    .foregroundColor(.gray)
                
                Circle()
                    .trim(from: remainingValue > basicGoal ? (1 - abs(progress)) : 0,
                          to: remainingValue > basicGoal ? 1 : abs(progress))
                    .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                    .foregroundColor(remainingValue < 0 ? .red : .orange)
                    .rotationEffect(Angle(degrees: 270))
                
                VStack {
                    Text("\(remainingValue)")
                        .font(.system(size: diameter * 0.2))
                        .fontWeight(.semibold)
                    Text("剩餘")
                        .font(.system(size: diameter * 0.12))
                        .foregroundColor(.gray)
                }
            }
            .aspectRatio(1, contentMode: .fit)
        }
    }
}

struct DataItemView: View {
    var title: String
    var value: Int
    var icon: String
    var unit: String?
    
    var isWidget: Bool
    
    var body: some View {
        if isWidget {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.orange)
                Spacer()
                HStack {
                    Text("\(value)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(" kcal")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
        } else {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.orange)
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(value)")
                        .font(.title3)
                        .fontWeight(.medium)
                }
            }
        }
    }
}

struct NutritionProgressView: View {
    var nutritionName: String
    var currentAmount: Double
    var totalAmount: Double
    var icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.orange)
            VStack(alignment: .leading) {
                Text(nutritionName)
                    .font(.caption)
                    .foregroundColor(.gray)
                ProgressView(value: min(currentAmount, totalAmount), total: totalAmount)
                    .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                Text("\(Int(currentAmount))/\(Int(totalAmount))g")
                    .font(.caption)
            }
            Spacer()
        }
    }
}
