//
//  HapticFeedbackHelper.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/10/11.
//

import UIKit

class HapticFeedbackHelper {
    
    static func generateImpactFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    static func generateNotificationFeedback(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
}
