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
    private var backgroundView: UIView?
    
    init(animationName: String = "FoodLoadingAnimation") {
        setupAnimation(animationName: animationName)
    }
    
    private func setupAnimation(animationName: String) {
        animationView = LottieAnimationView(name: animationName)
        animationView?.translatesAutoresizingMaskIntoConstraints = false
        animationView?.contentMode = .scaleAspectFit
        animationView?.loopMode = .loop
    }
    
    func show(in view: UIView, withBackground: Bool = false) {
        guard let animationView = animationView else { return }
        
        if withBackground {
            backgroundView = UIView(frame: view.bounds)
            backgroundView?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            backgroundView?.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(backgroundView!)
            
            NSLayoutConstraint.activate([
                backgroundView!.topAnchor.constraint(equalTo: view.topAnchor),
                backgroundView!.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                backgroundView!.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                backgroundView!.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        }
        
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
        backgroundView?.removeFromSuperview()
    }
}
