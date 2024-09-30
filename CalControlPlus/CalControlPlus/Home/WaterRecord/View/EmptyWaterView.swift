//
//  EmptyWaterView.swift
//  Test
//
//  Created by 楊芮瑊 on 2024/9/30.
//

import UIKit

class EmptyWaterView: UIView {

    private var cupLayer: CAShapeLayer!
    private var grayLayer: CAShapeLayer!
    
    private let insetRatio: CGFloat = 0.12
    private let waveHeightRatio: CGFloat = 0.1
    private lazy var inset = bounds.width * insetRatio
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCup()
        setupGrayLayer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateCupPath()
        updateGrayLayerMask()
    }
    
    private func setupCup() {
        cupLayer = CAShapeLayer()
        cupLayer.fillColor = UIColor.systemGray3.withAlphaComponent(0.3).cgColor
        layer.addSublayer(cupLayer)
    }
    
    private func setupGrayLayer() {
        grayLayer = CAShapeLayer()
        grayLayer.fillColor = UIColor.systemGray2.withAlphaComponent(0.5).cgColor
        layer.addSublayer(grayLayer)
    }
    
    private func updateCupPath() {
        let path = createCupPath()
        cupLayer.path = path.cgPath
    }
    
    private func updateGrayLayerMask() {
        grayLayer.path = createWaveCupPath().cgPath
    }
    
    private func createCupPath() -> UIBezierPath {
        let path = UIBezierPath()
        let width = bounds.width
        let height = bounds.height
        let cornerRadius: CGFloat = 5
        
        path.move(to: CGPoint(x: 0, y: cornerRadius))
        path.addQuadCurve(to: CGPoint(x: cornerRadius, y: 0), controlPoint: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: width - cornerRadius, y: 0))
        path.addQuadCurve(to: CGPoint(x: width, y: cornerRadius), controlPoint: CGPoint(x: width, y: 0))
        path.addQuadCurve(to: CGPoint(x: width * 0.85, y: height - cornerRadius), controlPoint: CGPoint(x: width, y: height * 0.5))
        path.addQuadCurve(to: CGPoint(x: width * 0.85 - cornerRadius, y: height), controlPoint: CGPoint(x: width * 0.85, y: height))
        path.addLine(to: CGPoint(x: width * 0.15 + cornerRadius, y: height))
        path.addQuadCurve(to: CGPoint(x: width * 0.15, y: height - cornerRadius), controlPoint: CGPoint(x: width * 0.15, y: height))
        path.addQuadCurve(to: CGPoint(x: 0, y: cornerRadius), controlPoint: CGPoint(x: 0, y: height * 0.5))
        path.close()
        return path
    }
    
    private func createWaveCupPath() -> UIBezierPath {
        let path = UIBezierPath()
        let width = bounds.width - inset * 2
        let height = bounds.height - inset * 2
        let cornerRadius: CGFloat = 5
        let waveHeightOffset: CGFloat = -(bounds.height * waveHeightRatio)
        
        // Move to top-left without rounded corner
        path.move(to: CGPoint(x: inset, y: bounds.height - waveHeightOffset - height))
        
        // Top horizontal line to top-right without rounded corner
        path.addLine(to: CGPoint(x: inset + width, y: bounds.height - waveHeightOffset - height))
        
        // Right side curve (same as original)
        path.addQuadCurve(to: CGPoint(x: inset + width * 0.85, y: inset + height - cornerRadius),
                          controlPoint: CGPoint(x: inset + width, y: inset + height * 0.5))
        
        // Bottom-right rounded corner
        path.addQuadCurve(to: CGPoint(x: inset + width * 0.85 - cornerRadius, y: inset + height),
                          controlPoint: CGPoint(x: inset + width * 0.85, y: inset + height))
        
        // Bottom line to bottom-left
        path.addLine(to: CGPoint(x: inset + width * 0.15 + cornerRadius, y: inset + height))
        
        // Bottom-left rounded corner
        path.addQuadCurve(to: CGPoint(x: inset + width * 0.15, y: inset + height - cornerRadius),
                          controlPoint: CGPoint(x: inset + width * 0.15, y: inset + height))
        
        // Left side curve
        path.addQuadCurve(to: CGPoint(x: inset, y: bounds.height - waveHeightOffset - height),
                          controlPoint: CGPoint(x: inset, y: inset + height * 0.5))
        
        path.close()
        return path
    }
}
