//
//  WeightRecordView.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/22.
//

import SwiftUI
import Charts
import FirebaseCore

struct LineChartView: View {
    var weightRecords: [WeightRecord]
    
    var body: some View {
        Chart {
            // 畫線，連接點
            ForEach(weightRecords, id: \.createdTime) { record in
                LineMark(
                    x: .value("Date", record.createdTime.dateValue(), unit: .day),
                    y: .value("Weight", record.weight)
                )
                .interpolationMethod(.linear) // 只連接點之間的線條
            }
            
            // 為每個紀錄點添加一個點
            ForEach(weightRecords, id: \.createdTime) { record in
                PointMark(
                    x: .value("Date", record.createdTime.dateValue(), unit: .day),
                    y: .value("Weight", record.weight)
                )
                .symbol(Circle())
                .symbolSize(40)
            }
        }
        .frame(height: 160)
        .chartYAxis {
            AxisMarks(position: .leading) { _ in
                AxisGridLine()
                AxisValueLabel()
            }
        }
        .chartXAxis {
            AxisMarks(values: weightRecords.map { $0.createdTime.dateValue() }) { value in
                            if let date = value.as(Date.self) {
                                AxisValueLabel(date.formatted(.dateTime.month(.defaultDigits).day(.defaultDigits)))
                            }
                        }
        }
        .chartXScale(domain: chartXScaleDomain()) // 設置 X 軸範圍，增加左右間距
        .padding()
    }
    
    // 計算 X 軸範圍，讓左右留一些間距
    private func chartXScaleDomain() -> ClosedRange<Date> {
        guard let firstDate = weightRecords.first?.createdTime.dateValue(),
              let lastDate = weightRecords.last?.createdTime.dateValue() else {
            return Date()...Date()
        }
        
        let paddingInterval: TimeInterval = 60 * 60 * 24 * 7 // 一週的間隔
        let paddedStartDate = firstDate.addingTimeInterval(-paddingInterval)
        let paddedEndDate = lastDate.addingTimeInterval(paddingInterval)
        
        return paddedStartDate...paddedEndDate
    }
}

struct WeightRecordView: View {
    @ObservedObject var viewModel: WeightRecordViewModel // 使用來自 ViewModel 的資料
    
    @State private var showingAddWeightSheet = false
    
    var body: some View {
        VStack {
            HStack {
                HStack(alignment: .bottom) {
                    Text("體重")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.leading, 10)
                    Text("(過去90天)")
                        .font(.caption2)
                }
                    
                Spacer()
                
                Button(action: {
                    showingAddWeightSheet = true
                }, label: {
                    Image(systemName: "plus")
                        .font(.title)
                        .padding()
                })
                .sheet(isPresented: $showingAddWeightSheet) {
                    AddWeightView(weightRecords: $viewModel.weightRecords, viewModel: viewModel)
                }
            }
            .padding(.bottom, 5)
            
            LineChartView(weightRecords: viewModel.weightRecords)
        }
        .padding(.horizontal)
    }
}

struct AddWeightView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var weightRecords: [WeightRecord]
    @ObservedObject var viewModel: WeightRecordViewModel
    
    @State private var weight: Double = 50.0
    @State private var date = Date()
    @State private var isEditingWeight = false
    
    var body: some View {
        NavigationView {
            Form {
                DatePicker("日期", selection: $date, displayedComponents: .date)
                
                HStack {
                    Text("體重")
                    
                    TextField("體重", value: $weight, format: .number)
                        .keyboardType(.decimalPad)
                        .frame(width: 100)
                        .multilineTextAlignment(.center)
                    
                    Text("kg")
                    
                    Spacer()
                    
                    Stepper("", value: $weight, in: 30...150, step: 0.1)
                        .labelsHidden()
                }
            }
            .navigationBarTitle("新增體重紀錄", displayMode: .inline)
            .navigationBarItems(leading: Button("取消") {
                dismiss()
            }, trailing: Button("儲存") {
                let newRecord = WeightRecord(createdTime: Timestamp(date: date), weight: weight)
                viewModel.addWeightRecord(newRecord)
                dismiss()
            })
        }
        .presentationDetents([.medium, .fraction(0.5)]) // 控制彈出視窗的高度
    }
}

// #Preview {
//    WeightRecordView()
//        .frame(width: 393, height: 300)
// }
