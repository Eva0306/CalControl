//
//  WeeklyNutriAnalysisView.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/19.
//

import SwiftUI
import Charts

struct PieSlice: Identifiable {
    let id = UUID()
    let startAngle: Angle
    let endAngle: Angle
    let color: Color
}

struct PieChartView: View {
    var slices: [PieSlice]
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let radius = min(width, height) / 2
            let center = CGPoint(x: width / 2, y: height / 2)
            
            ZStack {
                ForEach(slices) { slice in
                    Path { path in
                        path.addArc(
                            center: center,
                            radius: radius,
                            startAngle: slice.startAngle,
                            endAngle: slice.endAngle,
                            clockwise: false
                        )
                        path.addLine(to: center)
                        path.closeSubpath()
                    }
                    .fill(slice.color)
                }
            }
            .aspectRatio(1, contentMode: .fit)  // 确保保持1:1的比例
        }
    }
}

func calculateSlices(for values: [Double], colors: [Color]) -> [PieSlice] {
    var slices = [PieSlice]()
    var startAngle = Angle(degrees: 270)
    for (index, value) in values.enumerated() {
        let endAngle = startAngle + Angle(degrees: value * 360)
        let slice = PieSlice(startAngle: startAngle, endAngle: endAngle, color: colors[index])
        slices.append(slice)
        startAngle = endAngle
    }
    return slices
}

struct StackedBarChartView: View {
    var data: [WANutriData]
    
    var body: some View {
        Chart {
            ForEach(data, id: \.day) { item in
                BarMark(x: .value("Day", item.day), y: .value("Carbohydrate", item.carbohydrate))
                    .foregroundStyle(Color.orange)
                BarMark(x: .value("Day", item.day), y: .value("Fat", item.fat))
                    .foregroundStyle(Color.yellow)
                BarMark(x: .value("Day", item.day), y: .value("Protein", item.protein))
                    .foregroundStyle(Color.blue)
            }
            .cornerRadius(5)
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

struct WeeklyNutriAnalysisView: View {
    var dailyData: [WANutriData]
    var todayNutrition: [Double]
    var nutritionColors: [Color] = [.orange, .yellow, .blue]
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                Text("營養成分")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.bottom, 5)
                
                PieChartView(slices: calculateSlices(for: todayNutrition, colors: nutritionColors))
                    .frame(width: 100)
                
                VStack(alignment: .leading) {
                    HStack {
                        Circle().fill(Color.orange).frame(width: 10, height: 10)
                        Text("碳水化合物 33.3%")
                    }
                    HStack {
                        Circle().fill(Color.yellow).frame(width: 10, height: 10)
                        Text("脂肪 33.3%")
                    }
                    HStack {
                        Circle().fill(Color.blue).frame(width: 10, height: 10)
                        Text("蛋白質 33.3%")
                    }
                }
                .font(.caption)
            }
            
            VStack(alignment: .center) {
                StackedBarChartView(data: dailyData)
                
                Text("攝取均衡！繼續保持！")
                    .font(.body)
                    .foregroundColor(.gray)
            }
            .padding(.top, 30)
        }
        .padding()
    }
}

#Preview {
    WeeklyNutriAnalysisView(
        dailyData: [
            WANutriData(day: "Sun", carbohydrate: 0.3, fat: 0.3, protein: 0.4),
            WANutriData(day: "Mon", carbohydrate: 0.3, fat: 0.3, protein: 0.4),
            WANutriData(day: "Tue", carbohydrate: 0.4, fat: 0.2, protein: 0.4),
            WANutriData(day: "Wed", carbohydrate: 0.2, fat: 0.4, protein: 0.4),
            WANutriData(day: "Thu", carbohydrate: 0.4, fat: 0.3, protein: 0.3),
            WANutriData(day: "Fri", carbohydrate: 0.3, fat: 0.3, protein: 0.4),
            WANutriData(day: "Sat", carbohydrate: 0.3, fat: 0.3, protein: 0.4)
        ],
        todayNutrition: [0.33, 0.33, 0.34]
    )
    .frame(width: 393, height: 200)
}
