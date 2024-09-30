//
//  FillWaterView.swift
//  Test
//
//  Created by 楊芮瑊 on 2024/9/30.
//

import UIKit

class FillWaterView: UIView {

    private var cupLayer: CAShapeLayer!
    private var waveLayer: CAShapeLayer!

    private var waveFrequency: CGFloat = 2
    private var waveAmplitude: CGFloat = 2
    private var waveSpeed: CGFloat = 0.05
    private lazy var waveHeight: CGFloat = bounds.height
    private var phase: CGFloat = 0
    
    private let insetRatio: CGFloat = 0.12
    private let waveHeightRatio: CGFloat = 0.3

    private lazy var inset = bounds.width * insetRatio
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCup()
        setupWave()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateCupPath()
        updateWaveMask()
    }
    
    private func setupCup() {
        cupLayer = CAShapeLayer()
        cupLayer.fillColor = UIColor.cupBlue.cgColor
        layer.addSublayer(cupLayer)
    }
    
    private func setupWave() {
        waveLayer = CAShapeLayer()
        waveLayer.fillColor = UIColor.waterBlue.cgColor
        layer.addSublayer(waveLayer)
    }
    
    private func updateCupPath() {
        let path = createCupPath()
        cupLayer.path = path.cgPath
    }
    
    private func updateWaveMask() {
        let maskLayer = CAShapeLayer()
        maskLayer.path = createWaveCupPath().cgPath
        waveLayer.mask = maskLayer
    }
    
    private func createCupPath() -> UIBezierPath {
        let path = UIBezierPath()
        let width = bounds.width
        let height = bounds.height
        let cornerRadius: CGFloat = 5
        
        // Define the cup shape (no inset for the cup)
        path.move(to: CGPoint(x: 0, y: cornerRadius))
        path.addQuadCurve(to: CGPoint(x: cornerRadius, y: 0),
                          controlPoint: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: width - cornerRadius, y: 0))
        path.addQuadCurve(to: CGPoint(x: width, y: cornerRadius),
                          controlPoint: CGPoint(x: width, y: 0))
        path.addQuadCurve(to: CGPoint(x: width * 0.85, y: height - cornerRadius),
                          controlPoint: CGPoint(x: width, y: height * 0.5))
        path.addQuadCurve(to: CGPoint(x: width * 0.85 - cornerRadius, y: height),
                          controlPoint: CGPoint(x: width * 0.85, y: height))
        path.addLine(to: CGPoint(x: width * 0.15 + cornerRadius, y: height))
        path.addQuadCurve(to: CGPoint(x: width * 0.15, y: height - cornerRadius),
                          controlPoint: CGPoint(x: width * 0.15, y: height))
        path.addQuadCurve(to: CGPoint(x: 0, y: cornerRadius),
                          controlPoint: CGPoint(x: 0, y: height * 0.5))
        path.close()
        return path
    }
    
    // Use an inset for wave path
    private func createWaveCupPath() -> UIBezierPath {
        let path = UIBezierPath()
        let width = bounds.width - inset * 2
        let height = bounds.height - inset * 2
        let cornerRadius: CGFloat = 5
        
        path.move(to: CGPoint(x: inset, y: inset + cornerRadius))
        path.addQuadCurve(to: CGPoint(x: inset + cornerRadius, y: inset),
                          controlPoint: CGPoint(x: inset, y: inset))
        path.addLine(to: CGPoint(x: inset + width - cornerRadius, y: inset))
        path.addQuadCurve(to: CGPoint(x: inset + width, y: inset + cornerRadius),
                          controlPoint: CGPoint(x: inset + width, y: inset))
        path.addQuadCurve(to: CGPoint(x: inset + width * 0.85, y: inset + height - cornerRadius),
                          controlPoint: CGPoint(x: inset + width, y: inset + height * 0.5))
        path.addQuadCurve(to: CGPoint(x: inset + width * 0.85 - cornerRadius, y: inset + height),
                          controlPoint: CGPoint(x: inset + width * 0.85, y: inset + height))
        path.addLine(to: CGPoint(x: inset + width * 0.15 + cornerRadius, y: inset + height))
        path.addQuadCurve(to: CGPoint(x: inset + width * 0.15, y: inset + height - cornerRadius),
                          controlPoint: CGPoint(x: inset + width * 0.15, y: inset + height))
        path.addQuadCurve(to: CGPoint(x: inset, y: inset + cornerRadius),
                          controlPoint: CGPoint(x: inset, y: inset + height * 0.5))
        path.close()
        return path
    }
    
    @objc private func updateWave() {
        phase += waveSpeed
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: inset, y: waveHeight + inset))
        for x in 0...Int(bounds.width - inset * 2) {
            let y = waveAmplitude * sin(waveFrequency * CGFloat(x) * .pi / 180 + phase) + waveHeight
            path.addLine(to: CGPoint(x: CGFloat(x) + inset, y: y))
        }
        path.addLine(to: CGPoint(x: bounds.width - inset, y: bounds.height - inset))
        path.addLine(to: CGPoint(x: inset, y: bounds.height - inset))
        path.close()
        
        waveLayer.path = path.cgPath
    }
    
    func animateWaveView() {
        waveHeight = bounds.height
        waveAmplitude = 8
        waveSpeed = 0.1

        let displayLink = CADisplayLink(target: self, selector: #selector(animateWaveRise))
        displayLink.add(to: .main, forMode: .common)
    }
    
    @objc private func animateWaveRise(displayLink: CADisplayLink) {
        if waveHeight > bounds.height * waveHeightRatio {
            waveHeight -= 3
            updateWave()
        } else {
            displayLink.invalidate()
            stopWaveMotion()
        }
    }
    
    func stopWaveMotion() {
        waveAmplitude = 0
        waveSpeed = 0
        updateWave()
    }
}
