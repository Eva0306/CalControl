//
//  ProgressBarView.swift
//  FoodClassifier
//
//  Created by 楊芮瑊 on 2024/9/10.
//

import SwiftUI

struct ProgressBarView: View {
    @Binding var progress: Double  // 使用 @Binding 使进度可以外部传入
    
    var body: some View {
        ZStack {
            // 背景环
            Circle()
                .stroke(lineWidth: 10)
                .opacity(0.3)
                .foregroundColor(.gray)
            
            // 前景环，用来表示进度
            Circle()
                .trim(from: 0.0, to: progress)  // 使用 trim 来显示一部分圆形
                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                .foregroundColor(.orange)
                .rotationEffect(Angle(degrees: 270))  // 从顶部开始

            // 在环中心显示进度百分比
            Text(String(format: "%.0f %%", min(progress, 1.0) * 100.0))
                .font(.title)
                .bold()
        }
        .frame(width: 100, height: 100)  // 设置环的大小
    }
}

struct ContentView: View {
    @State private var progress: Double = 0.3
    
    var body: some View {
        VStack {
            ProgressBarView(progress: $progress)  // 传入进度绑定
                .padding()
            
            Button("Increase Progress") {
                withAnimation(.linear(duration: 0.5)) {
                    if progress < 1.0 {
                        progress += 0.1
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
