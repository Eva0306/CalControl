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
    
    var valueSize: Font
    var textSize: Font
    
    var isWidget: Bool
    
    var body: some View {
        if isWidget {
            ZStack {
                Circle()
                    .stroke(lineWidth: 8)
                    .opacity(0.3)
                    .foregroundColor(.gray)
                
                Circle()
                    .trim(from: remainingValue > basicGoal ? (1 - abs(progress)) : 0,
                          to: remainingValue > basicGoal ? 1 : abs(progress))
                    .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round))
                    .foregroundColor(remainingValue < 0 ? .red : .orange)
                    .rotationEffect(Angle(degrees: 270))
                
                VStack {
                    Text("\(remainingValue)")
                        .font(valueSize)
                        .fontWeight(.semibold)
                    Text("剩餘")
                        .font(textSize)
                        .foregroundColor(.gray)
                }
            }
            .aspectRatio(1, contentMode: .fit)
        } else {
            ZStack {
                Circle()
                    .stroke(lineWidth: 12)
                    .opacity(0.3)
                    .foregroundColor(.gray)
                
                Circle()
                    .trim(from: remainingValue > basicGoal ? (1 - abs(progress)) : 0,
                          to: remainingValue > basicGoal ? 1 : abs(progress))
                    .stroke(style: StrokeStyle(lineWidth: 12, lineCap: .round, lineJoin: .round))
                    .foregroundColor(remainingValue < 0 ? .red : .orange)
                    .rotationEffect(Angle(degrees: 270))
                
                VStack {
                    Text("\(remainingValue)")
                        .font(valueSize)
                        .fontWeight(.semibold)
                    Text("剩餘")
                        .font(textSize)
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
