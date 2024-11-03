//
//  Alert.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/10/11.
//

import UIKit

func showTemporaryAlert(
    on viewController: UIViewController,
    message: String,
    feedbackType: UINotificationFeedbackGenerator.FeedbackType? = nil
) {
    
    if let feedbackType = feedbackType {
        HapticFeedbackHelper.generateNotificationFeedback(type: feedbackType)
    }
    
    let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
    viewController.present(alertController, animated: true, completion: nil)

    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
        alertController.dismiss(animated: true, completion: nil)
    }
}

func showOKAlert(
    on viewController: UIViewController,
    title: String,
    message: String,
    feedbackType: UINotificationFeedbackGenerator.FeedbackType? = .error
) {
    if let feedbackType = feedbackType {
        HapticFeedbackHelper.generateNotificationFeedback(type: feedbackType)
    }
    
    let alertController = UIAlertController(
        title: title,
        message: message,
        preferredStyle: .alert
    )
    alertController.addAction(UIAlertAction(title: "確認", style: .default, handler: nil))
    viewController.present(alertController, animated: true, completion: nil)
}
