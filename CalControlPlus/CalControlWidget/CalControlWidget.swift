//
//  CalControlWidget.swift
//  CalControlWidget
//
//  Created by 楊芮瑊 on 2024/9/30.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            remainingValue: 500,
            progress: 0.25,
            basicGoal: 2000,
            foodValue: 1200,
            exerciseValue: 300,
            carbohydrateCurrent: 50,
            carbohydrateTotal: 100,
            proteinCurrent: 30,
            proteinTotal: 60,
            fatCurrent: 20,
            fatTotal: 40
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(
            date: Date(),
            remainingValue: 500,
            progress: 0.25,
            basicGoal: 2000,
            foodValue: 1200,
            exerciseValue: 300,
            carbohydrateCurrent: 50,
            carbohydrateTotal: 100,
            proteinCurrent: 30,
            proteinTotal: 60,
            fatCurrent: 20,
            fatTotal: 40
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        let sharedDefaults = UserDefaults(suiteName: "group.com.calControl.widget")
        
        let remainingValue = sharedDefaults?.integer(forKey: "remainingValue") ?? 0
        let progress = sharedDefaults?.double(forKey: "progress") ?? 0.0
        let basicGoal = sharedDefaults?.integer(forKey: "basicGoal") ?? 2000
        let foodValue = sharedDefaults?.integer(forKey: "foodValue") ?? 0
        let exerciseValue = sharedDefaults?.integer(forKey: "exerciseValue") ?? 0
        let carbohydrateCurrent = sharedDefaults?.double(forKey: "carbohydrateCurrent") ?? 0.0
        let carbohydrateTotal = sharedDefaults?.double(forKey: "carbohydrateTotal") ?? 0.0
        let proteinCurrent = sharedDefaults?.double(forKey: "proteinCurrent") ?? 0.0
        let proteinTotal = sharedDefaults?.double(forKey: "proteinTotal") ?? 0.0
        let fatCurrent = sharedDefaults?.double(forKey: "fatCurrent") ?? 0.0
        let fatTotal = sharedDefaults?.double(forKey: "fatTotal") ?? 0.0
        
        let entry = SimpleEntry(date: Date(),
                                remainingValue: remainingValue,
                                progress: progress,
                                basicGoal: basicGoal,
                                foodValue: foodValue,
                                exerciseValue: exerciseValue,
                                carbohydrateCurrent: carbohydrateCurrent,
                                carbohydrateTotal: carbohydrateTotal,
                                proteinCurrent: proteinCurrent,
                                proteinTotal: proteinTotal,
                                fatCurrent: fatCurrent,
                                fatTotal: fatTotal)
        
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }

}

struct SmallWidgetView: View {
    var entry: SimpleEntry
    
    var body: some View {
        VStack(alignment: .center) {
            ProgressBarView(progress: entry.progress,
                            remainingValue: entry.remainingValue,
                            basicGoal: entry.basicGoal)
            .frame(width: 50, height: 50)
            .padding(.bottom, 5)
            VStack(alignment: .leading, spacing: 4) {
                DataItemView(title: "基本目標", value: entry.basicGoal, icon: "flag", isWidget: true)
                DataItemView(title: "食物", value: entry.foodValue, icon: "fork.knife", isWidget: true)
                DataItemView(title: "運動", value: entry.exerciseValue, icon: "flame", isWidget: true)
            }
            .padding(.leading, 5)
            .padding(.trailing, 5)
        }
        .containerBackground(for: .widget) {
            Color.background
        }
    }
}

struct MediumWidgetView: View {
    var entry: SimpleEntry
    
    var body: some View {
        VStack {
            HStack {
                ProgressBarView(progress: entry.progress,
                                remainingValue: entry.remainingValue,
                                basicGoal: entry.basicGoal)
                .frame(width: 60, height: 60)
                    .padding(.leading, 30)
                Spacer()
                VStack(alignment: .leading, spacing: 4) {
                    DataItemView(title: "基本目標", value: entry.basicGoal, icon: "flag", isWidget: true)
                    DataItemView(title: "食物", value: entry.foodValue, icon: "fork.knife", isWidget: true)
                    DataItemView(title: "運動", value: entry.exerciseValue, icon: "flame", isWidget: true)
                }
                .padding(.leading, 60)
            }
            .padding(.horizontal)

            Divider()
            
            HStack(spacing: 4) {
                NutritionProgressView(nutritionName: "醣類",
                                      currentAmount: entry.carbohydrateCurrent,
                                      totalAmount: entry.carbohydrateTotal,
                                      icon: "leaf")
                NutritionProgressView(nutritionName: "蛋白質",
                                      currentAmount: entry.proteinCurrent,
                                      totalAmount: entry.proteinTotal,
                                      icon: "circle.grid.cross")
                NutritionProgressView(nutritionName: "脂肪",
                                      currentAmount: entry.fatCurrent,
                                      totalAmount: entry.fatTotal,
                                      icon: "drop")
            }
            .padding(.horizontal)
        }
        .containerBackground(for: .widget) {
            Color.background
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let remainingValue: Int
    let progress: Double
    let basicGoal: Int
    let foodValue: Int
    let exerciseValue: Int
    let carbohydrateCurrent: Double
    let carbohydrateTotal: Double
    let proteinCurrent: Double
    let proteinTotal: Double
    let fatCurrent: Double
    let fatTotal: Double
}

struct CalControlWidgetEntryView: View {
    var entry: SimpleEntry
    
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        default:
            EmptyView()
        }
    }
}

struct CalControlWidget: Widget {
    let kind: String = "YourWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            CalControlWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("卡路里追蹤")
        .description("追蹤每日熱量狀況。")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemMedium) {
    CalControlWidget()
} timeline: {
    SimpleEntry(
        date: Date(),
        remainingValue: 500,
        progress: 0.25,
        basicGoal: 2000,
        foodValue: 1200,
        exerciseValue: 300,
        carbohydrateCurrent: 50,
        carbohydrateTotal: 100,
        proteinCurrent: 30,
        proteinTotal: 60,
        fatCurrent: 20,
        fatTotal: 40
    )
}
