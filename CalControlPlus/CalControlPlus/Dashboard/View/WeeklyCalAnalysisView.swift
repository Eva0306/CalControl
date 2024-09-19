//
//  WeeklyCalAnalysisView.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/19.
//

import SwiftUI
import Charts

struct BarChartView: View {
    var data: [(day: String, value: Double)]
    var threshold: Double
    
    var body: some View {
        Chart {
            ForEach(data, id: \.day) { item in
                BarMark(
                    x: .value("Day", item.day),
                    y: .value("Value", item.value)
                )
                .foregroundStyle(item.value > threshold ? .mainRed : .mainGreen)
                .cornerRadius(5)
            }
            
            RuleMark(y: .value("Threshold", threshold))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                .foregroundStyle(.gray)
        }
        .frame(height: 120)
        .chartXAxis {
            AxisMarks(values: .automatic) { _ in
                AxisValueLabel()
            }
        }
        .chartYAxis(.hidden)
    }
}

struct WeeklyCalAnalysisView: View {
    
    var basicGoal: Int
    var foodValue: Int
    var exerciseValue: Int
    
    var netCalories: Int
    var bargetValue: Int
    var threshold: Double
    var weeklyCaloriesData: [(day: String, value: Double)]
    
    var remainingValue: Int {
        return basicGoal - foodValue + exerciseValue
    }
    
    var progress: Double {
        let calculatedProgress = Double(remainingValue) / Double(basicGoal)
        
        if remainingValue > basicGoal {
            return calculatedProgress - 1.0
        } else if remainingValue <= 0 {
            return calculatedProgress
        } else {
            return (Double(basicGoal) - Double(remainingValue)) / Double(basicGoal)
        }
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 30) {
            
            VStack(alignment: .leading, spacing: 10) {
                Text("卡路里")
                    .font(.title2)
                    .fontWeight(.medium)
                    .padding(.bottom, 10)
                
                VStack(alignment: .center, spacing: 20) {
                    ProgressBarView(progress: progress,
                                    remainingValue: remainingValue,
                                    basicGoal: basicGoal,
                                    valueSize: .title2,
                                    textSize: .caption)
                    .frame(width: 80)
                    
                    VStack(alignment: .leading) {
                        Text("淨卡路里:")
                            .fixedSize()
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        
                        Text("\(netCalories) 卡路里")
                            .font(.system(size: 14))
                            .bold()
                            .foregroundColor(netCalories < 0 ? .mainRed : Color(uiColor: .darkGray))
                    }
                }
            }
            
            VStack {
                BarChartView(data: weeklyCaloriesData, threshold: threshold)
                
                Text("本週預算尚餘 \(bargetValue)")
                    .font(.body)
                    .foregroundColor(.gray)
            }
            .padding(.vertical)
            .padding(.trailing, 10)
            
        }
        .padding()
    }
}

#Preview {
    WeeklyCalAnalysisView(basicGoal: 1000,
                       foodValue: 750,
                       exerciseValue: 0,
                       netCalories: 250,
                       bargetValue: 0,
                       threshold: 0.8,
                       weeklyCaloriesData: [
                        ("Sun", 0.8),
                        ("Mon", 0.7),
                        ("Tue", 0.7),
                        ("Wed", 0.7),
                        ("Thu", 0.94),
                        ("Fri", 0.6),
                        ("Sat", 0.6)
                       ]
    )
    .frame(width: 393, height: 200)
}
