//
//  MiSnapFacialCaptureCountdownView.swift
//  MiSnapFacialCaptureSampleApp
//
//  Created by Stas Tsuprenko on 8/26/20.
//  Copyright © 2020 Mitek Systems Inc. All rights reserved.
//

import UIKit

public enum MiSnapFacialCaptureCountdownStyle: String, Equatable {
    case simple, pulsate, infinity, burndUp
}

class MiSnapFacialCaptureCountdownView: UILabel {
    private let countdownTime: Int!
    private let style: MiSnapFacialCaptureCountdownStyle!
    
    // Change this value [0...1] to adjust transparency of this view
    private let countdownAlpha: CGFloat = 0.8
    
    // Change this value to adjust size of this view
    private let countdownViewSize: CGFloat = 100
    
    private var shouldStartBurnUp: Bool!
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(countdownTime: Int, style: MiSnapFacialCaptureCountdownStyle = .infinity) {
        self.countdownTime = countdownTime
        self.style = style
        self.shouldStartBurnUp = true
        
        let frame = CGRect(x: 0, y: 0, width: countdownViewSize, height: countdownViewSize)
        super.init(frame: frame)
        
        translatesAutoresizingMaskIntoConstraints = false
        textAlignment = .center
        numberOfLines = 1
        backgroundColor = .clear
        textColor = UIColor.black.withAlphaComponent(countdownAlpha)
        font = .systemFont(ofSize: 65, weight: .bold)
        layer.cornerRadius = frame.size.height / 2
        clipsToBounds = true
    }
    
    public func update(with value: Int) {
        text = String(describing: value)
        
        let localizedText = MiSnapFacialCaptureLocalizer.shared.localizedString(for: localizeKey(from: value))
        UIAccessibility.post(notification: .announcement, argument: localizedText)
        
        guard let style = style else { return }
        
        if style == .burndUp, shouldStartBurnUp {
            // Customization for "burndup" style
            shouldStartBurnUp = false
            
            let lineWidth: CGFloat = 10
            
            let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2, y: frame.size.height / 2),
                                          radius: frame.size.width / 2 - lineWidth,
                                          startAngle: CGFloat(-90).radians,
                                          endAngle: CGFloat(270).radians,
                                          clockwise: true)
            
            let circleLayer = CAShapeLayer()
            circleLayer.path = circlePath.cgPath
            circleLayer.fillColor = UIColor.clear.cgColor
            circleLayer.strokeColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1).withAlphaComponent(countdownAlpha).cgColor
            circleLayer.lineWidth = lineWidth
            circleLayer.lineCap = .round
            
            circleLayer.strokeEnd = 0.0
            
            layer.addSublayer(circleLayer)
            
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.duration = CFTimeInterval(self.countdownTime)
            animation.fromValue = 0
            animation.toValue = 1
            animation.timingFunction = CAMediaTimingFunction(name: .linear)
            
            circleLayer.strokeEnd = 1
            
            circleLayer.add(animation, forKey: "animateCircle")
            
            self.alpha = 0.0
            UIView.animate(withDuration: 0.4) { [unowned self] in
                self.alpha = 1.0
            }
        } else if style == .pulsate {
            // Customization for "pulsating" style
            let minScale: CGFloat = 0.7
            let maxScale: CGFloat = 1.3
            
            self.alpha = 0.0
            self.transform = CGAffineTransform(scaleX: minScale, y: minScale)
            
            UIView.animate(withDuration: 0.3) {
                self.alpha = 1.0
                self.transform = CGAffineTransform(scaleX: maxScale, y: maxScale)
            } completion: { _ in
                UIView.animate(withDuration: 0.2, delay: 0.1) {
                    self.alpha = 0.0
                    self.transform = CGAffineTransform(scaleX: minScale, y: minScale)
                }
            }
        } else if style == .infinity {
            // Customization for "infinity" style
            let minScale: CGFloat = 0.5
            let maxScale: CGFloat = 1.5
            
            self.alpha = 1.0
            self.transform = CGAffineTransform(scaleX: minScale, y: minScale)
            
            UIView.animate(withDuration: 0.5) { [unowned self] in
                self.alpha = 0.0
                self.transform = CGAffineTransform(scaleX: maxScale, y: maxScale)
            }
        }
        // Add your own custom style to "MiSnapFacialCaptureCountdownStyle" enum above and implement it here
    }
    
    private func localizeKey(from value: Int) -> String {
        switch value {
        case 3: return "misnap_facial_capture_ux_countdown_three"
        case 2: return "misnap_facial_capture_ux_countdown_two"
        case 1: return "misnap_facial_capture_ux_countdown_one"
        default: return ""
        }
    }
}

extension CGFloat {
    var radians: CGFloat { return self * CGFloat.pi / 180 }
}
