//
//  LoadingView.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/10/3.
//

import UIKit
import Lottie

class LoadingView {
    private var animationView: LottieAnimationView?
    
    init(animationName: String = "FoodLoadingAnimation") {
        setupAnimation(animationName: animationName)
    }
    
    private func setupAnimation(animationName: String) {
        animationView = LottieAnimationView(name: animationName)
        animationView?.translatesAutoresizingMaskIntoConstraints = false
        animationView?.contentMode = .scaleAspectFit
        animationView?.loopMode = .loop
    }
    
    func show(in view: UIView) {
        guard let animationView = animationView else { return }
        
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            animationView.widthAnchor.constraint(equalToConstant: 150),
            animationView.heightAnchor.constraint(equalToConstant: 150)
        ])
        
        animationView.play()
    }
    
    func hide() {
        animationView?.stop()
        animationView?.removeFromSuperview()
    }
}
