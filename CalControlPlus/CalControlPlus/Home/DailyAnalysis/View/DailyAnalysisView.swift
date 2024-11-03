//
//  DailyAnalysisView.swift
//  FoodClassifier
//
//  Created by 楊芮瑊 on 2024/9/10.
//

import SwiftUI

struct DailyAnalysisView: View {
    @ObservedObject var viewModel: DailyAnalysisViewModel
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("卡路里")
                    .font(.title2)
                    .bold()
                Spacer()
                Text(UserProfileViewModel.shared.user.target.description())
                    .font(.caption)
                    .padding(8)
                    .background(Color.mainOrg)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.top, 10)
            
            Text("剩餘量 = 基本目標 - 食物 + 運動")
                .font(.caption)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 20)
                .padding(.bottom, 20)
            
            HStack {
                ProgressBarView(progress: viewModel.progress,
                                remainingValue: viewModel.remainingValue,
                                basicGoal: viewModel.basicGoal)
                .frame(width: 150, height: 150)
                .padding(.leading, 40)
                .padding(.trailing, 40)
                
                VStack(alignment: .leading, spacing: 16) {
                    DataItemView(title: "基本目標", value: viewModel.basicGoal, icon: "flag", isWidget: false)
                    DataItemView(title: "食物", value: viewModel.foodValue, icon: "fork.knife", isWidget: false)
                    DataItemView(title: "運動", value: viewModel.exerciseValue, icon: "flame", isWidget: false)
                }
                Spacer()
            }
            .padding(.bottom, 20)
            
            Divider()
                .padding(.leading, 10)
                .padding(.trailing, 10)
            
            HStack(spacing: 10) {
                NutritionProgressView(nutritionName: "碳水化合物",
                                      currentAmount: viewModel.carbohydrateCurrent,
                                      totalAmount: viewModel.carbohydrateTotal,
                                      icon: "leaf")
                NutritionProgressView(nutritionName: "蛋白質",
                                      currentAmount: viewModel.proteinCurrent,
                                      totalAmount: viewModel.proteinTotal,
                                      icon: "circle.grid.cross")
                NutritionProgressView(nutritionName: "脂肪",
                                      currentAmount: viewModel.fatCurrent,
                                      totalAmount: viewModel.fatTotal,
                                      icon: "drop")
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
        .background(Color.clear)
    }
}
