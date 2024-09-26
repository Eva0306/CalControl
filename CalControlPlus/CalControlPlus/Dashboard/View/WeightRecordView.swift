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
            ForEach(weightRecords, id: \.createdTime) { record in
                LineMark(
                    x: .value("Date", record.createdTime.dateValue(), unit: .day),
                    y: .value("Weight", record.weight)
                )
                .interpolationMethod(.linear)
            }
            
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
                        .offset(y: 5)
                }
            }
        }
        .chartXScale(domain: chartXScaleDomain())
        .padding()
    }
    
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
    @ObservedObject var viewModel: WeightRecordViewModel
    
    @State private var showingAddWeightSheet = false
    
    var body: some View {
        VStack {
            HStack {
                HStack(alignment: .bottom) {
                    Text("體重")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text("(過去90天)")
                        .font(.caption2)
                }
                
                Spacer()
                
                Button(action: {
                    showingAddWeightSheet = true
                }, label: {
                    Image(systemName: "plus")
                        .font(.headline)
                })
                .sheet(isPresented: $showingAddWeightSheet) {
                    AddWeightView(weightRecords: $viewModel.weightRecords, viewModel: viewModel)
                }
            }
            .padding(.bottom, 5)
            
            ZStack(alignment: .bottomLeading) {
                LineChartView(weightRecords: viewModel.weightRecords)
                
                Text("(kg)")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(.leading, 8)
                    .padding(.bottom, 10)
            }
        }
        .padding()
    }
}

struct AddWeightView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var weightRecords: [WeightRecord]
    @ObservedObject var viewModel: WeightRecordViewModel
    
    @State private var weight: Double = 50.0
    @State private var currentDate = Calendar.current.startOfDay(for: Date())
    @State private var isEditingWeight = false
    
    @State private var showAlert = false
    @State private var replaceIndex: Int?
    
    var body: some View {
        NavigationView {
            Form {
                DatePicker("日期", selection: $currentDate, displayedComponents: .date)
                    .onChange(of: currentDate) {
                        checkIfRecordExists()
                    }
                
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
                if replaceIndex != nil {
                    showAlert = true
                } else {
                    viewModel.saveOrReplaceRecord(for: currentDate, weight: weight)
                    dismiss()
                }
            })
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("該日期已有資料"),
                    message: Text("要以此資料取代嗎？"),
                    primaryButton: .destructive(Text("取代")) {
                        viewModel.saveOrReplaceRecord(for: currentDate, weight: weight)
                        dismiss()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
        .onAppear {
            checkIfRecordExists()
        }
        .presentationDetents([.medium, .fraction(0.5)])
    }
    
    private func checkIfRecordExists() {
        if let result = viewModel.checkIfRecordExists(for: currentDate) {
            replaceIndex = result.index
            weight = result.weight
        } else {
            replaceIndex = nil
            weight = 50.0
        }
    }
}



// #Preview {
//    WeightRecordView()
//        .frame(width: 393, height: 300)
// }
