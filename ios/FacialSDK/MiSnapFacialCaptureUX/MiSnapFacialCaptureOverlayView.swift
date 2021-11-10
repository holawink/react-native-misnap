//
//  MiSnapFacialCaptureOverlayView.swift
//  MiSnapFacialCaptureSampleApp
//
//  Created by Stas Tsuprenko on 6/12/20.
//  Copyright © 2020 Mitek Systems Inc. All rights reserved.
//

import UIKit
import MiSnapFacialCapture

private enum MiSnapFacialCaptureScreenAspectRatio: String, Equatable {
    case none, fourByThree, sixteenByNine, greaterThanSixteenByNine
}

protocol MiSnapFacialCaptureOverlayViewDelegate: NSObject {
    func cancelButtonAction()
    func helpButtonAction()
    func manualSelectionButtonAction()
}

class MiSnapFacialCaptureOverlayView: UIView {
    private let parameters: MiSnapFacialCaptureParameters!
    private var results: MiSnapFacialCaptureResults?
    private weak var delegate: MiSnapFacialCaptureOverlayViewDelegate?
    
    private var cancelButton: UIButton = UIButton()
    private var helpButton: UIButton = UIButton()
    private var manualSelectionButton: UIButton = UIButton()
    
    private var statusLabel: UILabel = UILabel()
    
    private var countdownView: MiSnapFacialCaptureCountdownView!
    
    private var aspectRatio: MiSnapFacialCaptureScreenAspectRatio = .none
    private var ovalRect: CGRect = .zero
    private var messageTimer: Timer?
    private var success: Bool = false
    
    private var currentHintMessage: String = ""
    
    required init?(coder: NSCoder) {
        fatalError("MiSnapFacialCaptureOverlayView.init(coder:) has not been implemented")
    }
    
    public init(with parameters: MiSnapFacialCaptureParameters, delegate: MiSnapFacialCaptureOverlayViewDelegate, frame: CGRect) {
        self.parameters = parameters
        self.delegate = delegate
        
        super.init(frame: frame)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
        self.aspectRatio = self.aspectRatio(from: UIScreen.main.bounds.size)
        self.configureSubviews()
    }
    
    public func set(delegate: MiSnapFacialCaptureOverlayViewDelegate?) {
        self.delegate = delegate
    }
    
    public func update(_ mode: MiSnapFacialCaptureMode) {
        parameters.mode = mode
    }
    
    public func update(with results: MiSnapFacialCaptureResults) {
        self.results = results
        
        updateHintMessage(with: results.highestPriorityStatus)
        manageManualButton(for: results.highestPriorityStatus)
        
        setNeedsDisplay()
    }
    
    public func manageManualOnly() {
        manualSelectionButton.isHidden = false
        statusLabel.isHidden = true
    }
    
    public func addCountdownTimer(with style: MiSnapFacialCaptureCountdownStyle) {
        // Look and feel customization for Countdown View should be done in MiSnapFacialCaptureCountdownView.swift
        // Location on a screen and size is customized below in NSLayoutConstraint.activateConstraints
        countdownView = MiSnapFacialCaptureCountdownView(countdownTime: parameters.countdownTime, style: style)
        
        self.addSubview(countdownView)
        
        NSLayoutConstraint.activate([
            countdownView.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 10),
            countdownView.widthAnchor.constraint(equalToConstant: countdownView.frame.width),
            countdownView.heightAnchor.constraint(equalToConstant: countdownView.frame.height),
            countdownView.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
        
        countdownView.isHidden = true
    }
    
    public func removeCountdownTimer() {
        countdownView.layer.removeAllAnimations()
        countdownView.removeFromSuperview()
    }
    
    public func updateCountdownTimer(with value: Int) {
        countdownView.isHidden = false
        countdownView.update(with: value)
    }
    
    public func runSuccessAnimation() {
        success = true
        invalidateMessageTimer()
        configureSuccessAnimation()
    }
    
    public func removeSuccessAnimation() {
        success = false
        accessibilityElements = [statusLabel, manualSelectionButton, cancelButton, helpButton]
        if let v = viewWithTag(13) {
            v.removeFromSuperview()
        }
    }
}

extension MiSnapFacialCaptureOverlayView {
    // MARK: Button actions
    @objc private func cancelButtonAction() {
        delegate?.cancelButtonAction()
    }
    
    @objc private func helpButtonAction() {
        delegate?.helpButtonAction()
    }
    
    @objc private func manualSelectionButtonAction() {
        delegate?.manualSelectionButtonAction()
    }
}

extension MiSnapFacialCaptureOverlayView {
    // MARK: Customization
    private func configureSubviews() {
        // Look and feel customization for Status Label (Hint Message View)
        // Location on a screen and size is customized below in NSLayoutConstraint.activateConstraints
        statusLabel = UILabel(frame: CGRect(x: 0, y: 0, width: frame.size.width * 0.4, height: 40))
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.font = .systemFont(ofSize: 19, weight: .bold)
        statusLabel.textAlignment = .center
        statusLabel.textColor = .black
        statusLabel.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        statusLabel.layer.cornerRadius = statusLabel.frame.size.height / 2
        statusLabel.clipsToBounds = true
        
        // Look and feel customization for Cancel Button
        // Location on a screen and size is customized below in NSLayoutConstraint.activateConstraints
        cancelButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setImage(UIImage(named: "misnap_facial_capture_cancel"), for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonAction), for: .touchUpInside)
        cancelButton.isExclusiveTouch = true
        cancelButton.accessibilityLabel = MiSnapFacialCaptureLocalizer.shared.localizedString(for: "misnap_facial_capture_ux_tutorial_button_cancel")
        
        // Look and feel customization for Help Button
        // Location on a screen and size is customized below in NSLayoutConstraint.activateConstraints
        helpButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        helpButton.translatesAutoresizingMaskIntoConstraints = false
        helpButton.setImage(UIImage(named: "misnap_facial_capture_help"), for: .normal)
        helpButton.addTarget(self, action: #selector(helpButtonAction), for: .touchUpInside)
        helpButton.isExclusiveTouch = true
        helpButton.accessibilityLabel = MiSnapFacialCaptureLocalizer.shared.localizedString(for: "misnap_facial_capture_ux_tutorial_button_help")
        
        // Look and feel customization for Manual Selection Button
        // Location on a screen and size is customized below in NSLayoutConstraint.activateConstraints
        manualSelectionButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        manualSelectionButton.translatesAutoresizingMaskIntoConstraints = false
        manualSelectionButton.setImage(UIImage(named: "misnap_facial_capture_camera_shutter"), for: .normal)
        manualSelectionButton.addTarget(self, action: #selector(manualSelectionButtonAction), for: .touchUpInside)
        manualSelectionButton.isExclusiveTouch = true
        manualSelectionButton.accessibilityLabel = MiSnapFacialCaptureLocalizer.shared.localizedString(for: "misnap_facial_capture_ux_tutorial_button_select_frame")
        // DO NOT change hidden status as it's handled automatically
        manualSelectionButton.isHidden = true
        
        addSubview(statusLabel)
        addSubview(cancelButton)
        addSubview(helpButton)
        addSubview(manualSelectionButton)
        
        accessibilityElements = [statusLabel, manualSelectionButton, cancelButton, helpButton]
        UIAccessibility.post(notification: .screenChanged, argument: statusLabel)
        
        var statusLabelTopAnchorConstant: CGFloat = 0.0
        var statusLabelWidthAnchorConstant: CGFloat = 0.0
        var ovalWidthAdjuster: CGFloat = 1.0
        
        switch aspectRatio {
        case .fourByThree:
            statusLabelTopAnchorConstant = frame.size.height * 0.35
            statusLabelWidthAnchorConstant = frame.size.width * 0.5
        case .greaterThanSixteenByNine:
            statusLabelTopAnchorConstant = frame.size.height * 0.4
            statusLabelWidthAnchorConstant = frame.size.width * 0.75
            ovalWidthAdjuster = 1.218
        default:
            statusLabelTopAnchorConstant = frame.size.height * 0.43
            statusLabelWidthAnchorConstant = frame.size.width * 0.7
        }
        
        NSLayoutConstraint.activate([
            // Location and size customization for Status Label (Hint Message View)
            statusLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            statusLabel.topAnchor.constraint(equalTo: topAnchor, constant: statusLabelTopAnchorConstant),
            statusLabel.widthAnchor.constraint(equalToConstant: statusLabelWidthAnchorConstant),
            statusLabel.heightAnchor.constraint(equalToConstant: 40),
            
            // Location and size customization for Cancel Button
            cancelButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            cancelButton.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            cancelButton.widthAnchor.constraint(equalToConstant: 40),
            cancelButton.heightAnchor.constraint(equalToConstant: 40),
            
            // Location and size customization for Help Button
            helpButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
            helpButton.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            helpButton.widthAnchor.constraint(equalToConstant: 40),
            helpButton.heightAnchor.constraint(equalToConstant: 40),
            
            // Location and size customization for Manual Selection Button
            manualSelectionButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            manualSelectionButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -60),
            manualSelectionButton.widthAnchor.constraint(equalToConstant: 60),
            manualSelectionButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        let screenSize = normalizedSize(from: UIScreen.main.bounds.size)
        
        // Look and feel, location and size customization for Oval
        let w: CGFloat = screenSize.width * (CGFloat(parameters.maxFill) / 1000.0) * ovalWidthAdjuster
        let ovalAr: CGFloat = 1.333
        let h: CGFloat = w * ovalAr
        let x: CGFloat = (screenSize.width - w) / 2.0
        let y: CGFloat = (screenSize.height - h) / 2.0
        
        ovalRect = CGRect(x: x, y: y, width: w, height: h)
        // Oval is drawn in drawOval(in context, rect)
        
        if parameters.cameraParameters.recordVideo && parameters.cameraParameters.showRecordingUI {
            addRecordingUI()
        }
    }
    
    private func addRecordingUI() {
        removeRecordingUI()
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 110, height: 30))
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        containerView.tag = 11
        containerView.layer.cornerRadius = containerView.frame.height / 2
        
        let redDotView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        redDotView.translatesAutoresizingMaskIntoConstraints = false
        redDotView.backgroundColor = .red
        redDotView.layer.cornerRadius = redDotView.frame.height / 2
        
        containerView.addSubview(redDotView)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = MiSnapFacialCaptureLocalizer.shared.localizedString(for: "misnap_facial_capture_ux_record")
        label.font = .systemFont(ofSize: 15.0, weight: .light)
        label.textAlignment = .center
        label.textColor = .black
        
        containerView.addSubview(label)
        
        addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: ovalRect.origin.y - containerView.frame.height - 10),
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.widthAnchor.constraint(equalToConstant: containerView.frame.width),
            containerView.heightAnchor.constraint(equalToConstant: containerView.frame.height),
            
            redDotView.widthAnchor.constraint(equalToConstant: redDotView.frame.width),
            redDotView.heightAnchor.constraint(equalToConstant: redDotView.frame.height),
            redDotView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            redDotView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 10),
            
            label.leftAnchor.constraint(equalTo: redDotView.rightAnchor, constant: 5),
            label.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -10),
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
        
        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       options: [.autoreverse, .repeat],
                       animations: {
                        redDotView.alpha = 0.0
                       }, completion: nil)
    }
    
    private func removeRecordingUI() {
        if let v = viewWithTag(11) {
            v.removeFromSuperview()
        }
    }
    
    public func addInterruptionView(withMessage message: String) {
        removeInterruptionView()
        
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.frame = frame
        blurView.tag = 12
        
        let label = UILabel(frame: blurView.frame)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 5
        label.text = message
        label.textColor = .black
        label.font = .systemFont(ofSize: 35, weight: .bold)
        label.textAlignment = .center
        label.layer.shadowOffset = CGSize(width: 0, height: 0)
        label.layer.shadowColor = UIColor.white.cgColor
        label.layer.shadowRadius = 2
        label.layer.shadowOpacity = 0.9
        
        blurView.contentView.addSubview(label)
        addSubview(blurView)
        
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
            blurView.leftAnchor.constraint(equalTo: leftAnchor),
            blurView.rightAnchor.constraint(equalTo: rightAnchor),
            
            label.topAnchor.constraint(equalTo: blurView.topAnchor),
            label.bottomAnchor.constraint(equalTo: blurView.bottomAnchor),
            label.leftAnchor.constraint(equalTo: blurView.leftAnchor),
            label.rightAnchor.constraint(equalTo: blurView.rightAnchor)
        ])
    }
    
    public func removeInterruptionView() {
        if let v = viewWithTag(12) {
            v.removeFromSuperview()
        }
        
        // Re-add recording UI to make sure a red dot is being animated
        if parameters.cameraParameters.recordVideo && parameters.cameraParameters.showRecordingUI {
            addRecordingUI()
        }
    }
    
    private func updateHintMessage(with highestPriorityStatus: MiSnapFacialCaptureStatus) {
        if let _ = messageTimer {
            return
        } else {
            startMessageTimer()
        }
        
        var localizeKey = MiSnapFacialCaptureResults.localizeKey(from: highestPriorityStatus)
        
        if highestPriorityStatus == .good, parameters.mode == .manual {
            localizeKey += "_manual"
        } else if highestPriorityStatus == .good, parameters.mode == .auto {
            localizeKey = parameters.selectOnSmile ? localizeKey + "_auto" : ""
        }
        
        //In MiSnapFacialCaptureLocalizable.strings, modify values for keys "misnap_facial_capture_status_..." to customize hint messages text
        let localizedText = MiSnapFacialCaptureLocalizer.shared.localizedString(for: localizeKey)
        statusLabel.text = localizedText
        statusLabel.accessibilityLabel = localizedText
        
        let font: UIFont = .systemFont(ofSize: 19, weight: .bold)
        let fontAdjuster: CGFloat = aspectRatio == .sixteenByNine ? 2 : 0
        let fontSize: CGFloat = UIFont.bestFittingFontSize(for: localizedText, in: statusLabel.frame, fontDescriptor: font.fontDescriptor) - fontAdjuster
        statusLabel.font = localizedText.count <= 28 || UIDevice.current.userInterfaceIdiom == .pad ? font : .systemFont(ofSize: fontSize, weight: .bold)
        
        if currentHintMessage != localizedText {
            currentHintMessage = localizedText
            UIAccessibility.post(notification: .announcement, argument: localizedText)
        }
    }
    
    public func manageManualButton(for highestPriorityStatus: MiSnapFacialCaptureStatus) {
        // Uncomment if you want Manual button to be hidden in Manual mode if face is not in a view so an end user cannot take any random picture
        //manualSelectionButton.isHidden = parameters.mode == .manual ? highestPriorityStatus == .faceNotFound ? true : false : true
        manualSelectionButton.isHidden = parameters.mode == .manual ? false : true
    }
    
    private func configureSuccessAnimation() {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.tag = 13
        containerView.backgroundColor = .white
        if #available(iOS 13.0, *) {
            containerView.backgroundColor = .systemBackground
        }
        
        addSubview(containerView)
        
        let successLabel = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width * 0.9, height: frame.height * 0.1))
        successLabel.translatesAutoresizingMaskIntoConstraints = false
        successLabel.text = MiSnapFacialCaptureLocalizer.shared.localizedString(for: "misnap_facial_capture_ux_success")
        successLabel.numberOfLines = 2
        successLabel.textAlignment = .center
        successLabel.font = UIFont.bestFittingFont(for: successLabel.text ?? "", in: successLabel.frame, fontDescriptor: UIFont.systemFont(ofSize: 20).fontDescriptor)
        successLabel.font = .systemFont(ofSize: successLabel.font.pointSize - 3)
        successLabel.textColor = .black
        if #available(iOS 13.0, *) {
            successLabel.textColor = .label
        }
        
        containerView.addSubview(successLabel)
        
        let multiplier: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 0.15 : 0.25
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width * multiplier, height: frame.width * 0.25))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "misnap_facial_capture_success_checkmark")
        imageView.contentMode = .scaleAspectFit
        
        containerView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.leftAnchor.constraint(equalTo: leftAnchor),
            containerView.rightAnchor.constraint(equalTo: rightAnchor),
            
            imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: -20),
            imageView.widthAnchor.constraint(equalToConstant: imageView.frame.width),
            imageView.heightAnchor.constraint(equalToConstant: imageView.frame.height),
            
            successLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            successLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
            successLabel.widthAnchor.constraint(equalToConstant: successLabel.frame.width),
            successLabel.heightAnchor.constraint(equalToConstant: successLabel.frame.height)
        ])
        
        accessibilityElements = []
        UIAccessibility.post(notification: .announcement, argument: successLabel)
    }
}

extension MiSnapFacialCaptureOverlayView {
    private func normalizedSize(from size: CGSize) -> CGSize {
        if size.width > size.height {
            return CGSize(width: size.height, height: size.width)
        }
        return size
    }
    
    private func aspectRatio(from screenSize: CGSize) -> MiSnapFacialCaptureScreenAspectRatio {
        var aspectRatio: MiSnapFacialCaptureScreenAspectRatio = .none
        
        let ar: CGFloat = screenSize.width > screenSize.height ? screenSize.width / screenSize.height : screenSize.height / screenSize.width
        
        if ar > 1.33 && ar < 1.76 {
            aspectRatio = .fourByThree
        } else if ar > 1.77 && ar < 1.78 {
            aspectRatio = .sixteenByNine
        } else if ar >= 1.78 {
            aspectRatio = .greaterThanSixteenByNine
        }
        
        return aspectRatio
    }
    
    private func startMessageTimer() {
        messageTimer = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(invalidateMessageTimer), userInfo: nil, repeats: false)
    }
    
    @objc private func invalidateMessageTimer() {
        if let timer = messageTimer {
            timer.invalidate()
            messageTimer = nil
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if success { return }
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.clear(rect)
        
        drawOval(in: context, rect: rect)
        
        guard parameters.highlightLandmarks, let results = results else { return }
        //drawBoundingBox(in: context, from: results)
        drawFaceCountour(in: context, from: results)
        drawNoseCrest(in: context, from: results)
        drawNose(in: context, from: results)
        drawEyes(in: context, from: results)
        drawOuterLips(in: context, from: results)
    }
    
    private func drawOval(in context: CGContext, rect: CGRect) {
        context.setFillColor(UIColor.white.withAlphaComponent(0.3).cgColor)
        context.fill(rect)
        context.setBlendMode(.clear)
        context.fillEllipse(in: ovalRect)
        context.setBlendMode(.normal)
        if let results = results, results.highestPriorityStatus == .good || results.highestPriorityStatus == .countdown {
            context.setStrokeColor(#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1).cgColor)
        } else {
            context.setStrokeColor(#colorLiteral(red: 1, green: 0, blue: 0, alpha: 1).cgColor)
        }
        context.setLineWidth(2.0)
        context.strokeEllipse(in: ovalRect)
    }
    
    private func drawBoundingBox(in context: CGContext, from results: MiSnapFacialCaptureResults) {
        guard !results.faceRect.equalTo(CGRect.zero) else { return }
        
        context.setStrokeColor(UIColor.orange.cgColor)
        context.stroke(results.faceRect)
    }
    
    private func drawFaceCountour(in context: CGContext, from results: MiSnapFacialCaptureResults, pointDiameter: CGFloat = 6.0) {
        guard let faceContourPoints = results.faceContourPoints as? [CGPoint] else { return }

        context.setStrokeColor(UIColor.green.cgColor)
        context.setLineWidth(3.0)

        for i in (0..<faceContourPoints.count) {
            if i == 0 {
                context.move(to: faceContourPoints[i])
            } else {
                context.addLine(to: faceContourPoints[i])
            }
        }
        context.strokePath()

        let faceContourLeft = faceContourPoints[faceContourPoints.count == 17 ? 16 : 0]
        context.setFillColor(UIColor.blue.cgColor)
        context.fillEllipse(in: CGRect(x: faceContourLeft.x - pointDiameter / 2, y: faceContourLeft.y - pointDiameter / 2, width: pointDiameter, height: pointDiameter))

        let faceContourRight = faceContourPoints[faceContourPoints.count == 17 ? 0 : 10]
        context.setFillColor(UIColor.red.cgColor)
        context.fillEllipse(in: CGRect(x: faceContourRight.x - pointDiameter / 2, y: faceContourRight.y - pointDiameter / 2, width: pointDiameter, height: pointDiameter))

        let faceContourMiddle = faceContourPoints[faceContourPoints.count == 17 ? 8 : 5]
        context.setFillColor(UIColor.yellow.cgColor)
        context.fillEllipse(in: CGRect(x: faceContourMiddle.x - pointDiameter / 2, y: faceContourMiddle.y - pointDiameter / 2, width: pointDiameter, height: pointDiameter))
    }
    
    private func drawNoseCrest(in context: CGContext, from results: MiSnapFacialCaptureResults) {
        guard let noseCrestPoints = results.noseCrestPoints as? [CGPoint] else { return }
        
        for i in (0..<noseCrestPoints.count) {
            if i == 0 {
                context.move(to: noseCrestPoints[i])
            } else {
                context.addLine(to: noseCrestPoints[i])
            }
        }
        context.strokePath()
    }
    
    private func drawNose(in context: CGContext, from results: MiSnapFacialCaptureResults, pointDiameter: CGFloat = 6.0) {
        guard let nosePoints = results.nosePoints as? [CGPoint] else { return }
        
        for i in (0..<nosePoints.count) {
            if i == 0 {
                context.move(to: nosePoints[i])
            } else {
                context.addLine(to: nosePoints[i])
            }
        }
        context.addLine(to: nosePoints[0])
        context.strokePath()
        
        let noseLeft = nosePoints[6]
        context.setFillColor(UIColor.red.cgColor)
        context.fillEllipse(in: CGRect(x: noseLeft.x - pointDiameter / 2, y: noseLeft.y - pointDiameter / 2, width: pointDiameter, height: pointDiameter))
        
        let noseRight = nosePoints[2]
        context.setFillColor(UIColor.blue.cgColor)
        context.fillEllipse(in: CGRect(x: noseRight.x - pointDiameter / 2, y: noseRight.y - pointDiameter / 2, width: pointDiameter, height: pointDiameter))

        let noseMiddle = nosePoints[4]
        context.setFillColor(UIColor.yellow.cgColor)
        context.fillEllipse(in: CGRect(x: noseMiddle.x - pointDiameter / 2, y: noseMiddle.y - pointDiameter / 2, width: pointDiameter, height: pointDiameter))
    }
    
    private func drawEyes(in context: CGContext, from results: MiSnapFacialCaptureResults) {
        guard let leftEyePoints = results.leftEyePoints as? [CGPoint], let rightEyePoints = results.rightEyePoints as? [CGPoint] else { return }
        
        for i in (0..<leftEyePoints.count) {
            if i == 0 {
                context.move(to: leftEyePoints[i])
            } else {
                context.addLine(to: leftEyePoints[i])
            }
        }
        context.addLine(to: leftEyePoints[0])
        context.strokePath()
        
        for i in (0..<rightEyePoints.count) {
            if i == 0 {
                context.move(to: rightEyePoints[i])
            } else {
                context.addLine(to: rightEyePoints[i])
            }
        }
        context.addLine(to: rightEyePoints[0])
        context.strokePath()
    }
    
    private func drawOuterLips(in context: CGContext, from results: MiSnapFacialCaptureResults, pointDiameter: CGFloat = 6.0) {
        guard let outerLipsPoints = results.outerLipsPoints as? [CGPoint] else { return }
        
        for i in (0..<outerLipsPoints.count) {
            if i == 0 {
                context.move(to: outerLipsPoints[i])
            } else {
                context.addLine(to: outerLipsPoints[i])
            }
        }
        context.addLine(to: outerLipsPoints[0])
        context.strokePath()
        
        let lipTop = outerLipsPoints[outerLipsPoints.count == 14 ? 3 : 2]
        let lipBottom = outerLipsPoints[outerLipsPoints.count == 14 ? 10 : 7]
        context.setFillColor(UIColor.yellow.cgColor)
        context.fillEllipse(in: CGRect(x: lipTop.x - pointDiameter / 2, y: lipTop.y - pointDiameter / 2, width: pointDiameter, height: pointDiameter))
        context.fillEllipse(in: CGRect(x: lipBottom.x - pointDiameter / 2, y: lipBottom.y - pointDiameter / 2, width: pointDiameter, height: pointDiameter))
        
        let lipLeft = outerLipsPoints[outerLipsPoints.count == 14 ? 13 : 9]
        context.setFillColor(UIColor.blue.cgColor)
        context.fillEllipse(in: CGRect(x: lipLeft.x - pointDiameter / 2, y: lipLeft.y - pointDiameter / 2, width: pointDiameter, height: pointDiameter))
        
        let lipRight = outerLipsPoints[outerLipsPoints.count == 14 ? 7 : 5]
        context.setFillColor(UIColor.red.cgColor)
        context.fillEllipse(in: CGRect(x: lipRight.x - pointDiameter / 2, y: lipRight.y - pointDiameter / 2, width: pointDiameter, height: pointDiameter))
    }
}
