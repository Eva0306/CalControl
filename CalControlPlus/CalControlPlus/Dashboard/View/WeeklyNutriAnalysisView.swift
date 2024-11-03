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
    var lineSpacing: CGFloat = 1
    
    let lineColor = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ? .lightGray : .white
    })
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let radius = min(width, height) / 2 - lineSpacing
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
                
                ForEach(slices) { slice in
                    Path { path in
                        let startPoint = CGPoint(
                            x: center.x + radius * CGFloat(cos(slice.startAngle.radians)),
                            y: center.y + radius * CGFloat(sin(slice.startAngle.radians))
                        )
                        let endPoint = CGPoint(
                            x: center.x + radius * CGFloat(cos(slice.endAngle.radians)),
                            y: center.y + radius * CGFloat(sin(slice.endAngle.radians))
                        )
                        
                        path.move(to: center)
                        path.addLine(to: startPoint)
                        path.move(to: center)
                        path.addLine(to: endPoint)
                    }
                    .stroke(lineColor, lineWidth: lineSpacing)
                }
            }
            .aspectRatio(1, contentMode: .fit)
        }
    }
}

func calculateSlices(for values: [Double]) -> [PieSlice] {
    var slices = [PieSlice]()
    var startAngle = Angle(degrees: 270)

    let allZero = values.allSatisfy { $0 == 0 }
    let finalValues = allZero ? [0.33, 0.33, 0.34] : values
    
    for (index, value) in finalValues.enumerated() {
        let endAngle = startAngle + Angle(degrees: value * 360)
        let nutritionType = NutritionType.allCases[index % NutritionType.allCases.count]
        let slice = PieSlice(startAngle: startAngle, endAngle: endAngle, color: nutritionType.color)
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
                if item.carbohydrate == 0 && item.protein == 0 && item.fat == 0 {
                    BarMark(x: .value("Day", item.day), y: .value("Placeholder", 1.0))
                        .foregroundStyle(Color.gray.opacity(0.3))
                } else {
                    BarMark(x: .value("Day", item.day), y: .value("Carbohydrate", item.carbohydrate))
                        .foregroundStyle(.mainOrg)
                    BarMark(x: .value("Day", item.day), y: .value("Protein", item.protein))
                        .foregroundStyle(.mainBlue)
                    BarMark(x: .value("Day", item.day), y: .value("Fat", item.fat))
                        .foregroundStyle(.mainYellow)
                }
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
    @ObservedObject var viewModel: WeeklyAnalysisViewModel

    var body: some View {
        HStack(alignment: .bottom, spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                Text("營養成分")
                    .font(.title3)
                    .fontWeight(.bold)
                VStack(alignment: .center) {
                    PieChartView(slices: calculateSlices(for: viewModel.todayNutrition))
                        .frame(width: 70, height: 70)
                    
                    VStack(alignment: .leading) {
                        ForEach(NutritionType.allCases, id: \.self) { nutrition in
                            HStack {
                                Circle().fill(nutrition.color).frame(width: 10, height: 10)
                                let index = NutritionType.allCases.firstIndex(of: nutrition) ?? 0
                                Text("\(nutrition.displayName)" +
                                     "\(String(format: "%.1f", viewModel.todayNutrition[index] * 100))%")
                            }
                        }
                    }
                    .font(.caption)
                }
            }
            
            StackedBarChartView(data: viewModel.weeklyNutritionData)
                .padding(.top, 40)
        }
        .padding()
        .background(Color.clear)
    }
}
