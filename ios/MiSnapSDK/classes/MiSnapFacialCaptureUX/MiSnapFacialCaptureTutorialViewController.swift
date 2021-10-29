//
//  MiSnapFacialCaptureTutorialViewController.swift
//  MiSnapFacialCaptureSampleApp
//
//  Created by Stas Tsuprenko on 6/12/20.
//  Copyright © 2020 Mitek Systems Inc. All rights reserved.
//

import UIKit
import MiSnapFacialCapture

protocol MiSnapFacialCaptureTutorialViewControllerDelegate: NSObject {
    func tutorialCancelButtonAction()
    func tutorialContinueButtonAction(for tutorialMode: MiSnapFacialCaptureTuturialMode)
    func tutorialRetryButtonAction(for tutorialMode: MiSnapFacialCaptureTuturialMode)
}

class MiSnapFacialCaptureTutorialViewController: UIViewController {
    private let tutorialMode: MiSnapFacialCaptureTuturialMode!
    private weak var delegate: MiSnapFacialCaptureTutorialViewControllerDelegate?
    private let parameters: MiSnapFacialCaptureParameters!
    private let image: UIImage?
    
    private var cancelButton: UIButton!
    private var retryButton: UIButton!
    private var continueButton: UIButton!
    private var buttonStackView: UIStackView!
    
    private let manualSelectionOnly: Bool
    
    required init?(coder: NSCoder) {
        fatalError("MiSnapFacialCaptureTutorialViewController.init(coder:) has not been implemented")
    }
    
    public init(for tutorialMode: MiSnapFacialCaptureTuturialMode, delegate: MiSnapFacialCaptureTutorialViewControllerDelegate, parameters: MiSnapFacialCaptureParameters, manualOnly: Bool = false, image: UIImage? = nil) {
        self.tutorialMode = tutorialMode
        self.delegate = delegate
        self.parameters = parameters
        self.manualSelectionOnly = manualOnly
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureSubviews()
    }
    
    public func set(delegate: MiSnapFacialCaptureTutorialViewControllerDelegate?) {
        self.delegate = delegate
    }
    
    deinit {
        print("MiSnapFacialCaptureTutorialViewController is deinitialized")
    }
}

extension MiSnapFacialCaptureTutorialViewController {
    @objc private func tutorialCancelButtonAction() {
        delegate?.tutorialCancelButtonAction()
    }
    
    @objc private func tutorialContinueButtonAction() {
        delegate?.tutorialContinueButtonAction(for: tutorialMode)
    }
    
    @objc private func tutorialRetryButtonAction() {
        delegate?.tutorialRetryButtonAction(for: tutorialMode)
    }
}

extension MiSnapFacialCaptureTutorialViewController {
    private func configureSubviews() {
        configureForGeneric()
        
        switch tutorialMode {
        case .instruction:  configureForInstruction()
        case .help:         configureForInstruction()
        case .timeout:      configureForTimeout()
        case .review:       configureForReview(with: image)
        default:            break
        }
    }
    
    private func configureForGeneric() {
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }
        
        // Look and feel customization for Cancel Button
        // Location on a screen and size is customized below in NSLayoutConstraint.activateConstraints
        cancelButton = UIButton(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 60))
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(tutorialCancelButtonAction), for: .touchUpInside)
        cancelButton.backgroundColor = .black
        cancelButton.isExclusiveTouch = true
        let buttonText = MiSnapFacialCaptureLocalizer.shared.localizedString(for: "misnap_facial_capture_ux_tutorial_button_cancel")
        cancelButton.setTitle(buttonText, for: .normal)
        cancelButton.accessibilityLabel = buttonText
        cancelButton.titleLabel?.numberOfLines = 2
        cancelButton.titleLabel?.textAlignment = .center
        
        // Look and feel customization for Continue Button
        // Location on a screen and size is customized below in NSLayoutConstraint.activateConstraints
        // Continue Button Text is customized in configureForInstruction(), configureForHelp(for:), configureForTimeout() depending on tutorialMode
        continueButton = UIButton(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 60))
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.addTarget(self, action: #selector(tutorialContinueButtonAction), for: .touchUpInside)
        continueButton.backgroundColor = #colorLiteral(red: 1, green: 0.1528493166, blue: 0.213029772, alpha: 1)
        continueButton.layer.cornerRadius = 20.0
        continueButton.isExclusiveTouch = true
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.titleLabel?.numberOfLines = 2
        continueButton.titleLabel?.textAlignment = .center
        
        // Look and feel customization for Retry Button
        // Location on a screen and size is customized below in NSLayoutConstraint.activateConstraints
        retryButton = UIButton(frame: CGRect(x: 0, y: 0, width: view.frame.size.width / 2, height: 60))
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        retryButton.addTarget(self, action: #selector(tutorialRetryButtonAction), for: .touchUpInside)
        retryButton.backgroundColor = #colorLiteral(red: 0.9882352941, green: 0, blue: 0.1647058824, alpha: 1)
        retryButton.layer.cornerRadius = 20.0
        retryButton.isExclusiveTouch = true
        retryButton.setTitle(buttonText, for: .normal)
        retryButton.setTitleColor(.white, for: .normal)
        retryButton.accessibilityLabel = buttonText
        // DO NOT override hidden and enabled status as it's handled automatically
        retryButton.isHidden = true
        retryButton.isEnabled = false
        retryButton.titleLabel?.numberOfLines = 2
        retryButton.titleLabel?.textAlignment = .center

        buttonStackView = UIStackView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 60))
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 20
        
        buttonStackView.addArrangedSubview(retryButton)
        buttonStackView.addArrangedSubview(continueButton)
        
        view.addSubview(cancelButton)
        view.addSubview(buttonStackView)
        
        var bottomAnchor = view.bottomAnchor
        if #available(iOS 11.0, *) {
            bottomAnchor = view.safeAreaLayoutGuide.bottomAnchor
        }
        
        NSLayoutConstraint.activate([
            cancelButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            cancelButton.leftAnchor.constraint(equalTo: view.leftAnchor),
            cancelButton.rightAnchor.constraint(equalTo: view.rightAnchor),
            cancelButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func configureForInstruction() {
        let buttonText = MiSnapFacialCaptureLocalizer.shared.localizedString(for: "misnap_facial_capture_ux_tutorial_button_continue")
        continueButton.setTitle(buttonText, for: .normal)
        continueButton.accessibilityLabel = buttonText
        
        let doLabel = label(withFrame: CGRect(x: 0, y: 0, width: 100, height: 30), localizeKey: "misnap_facial_capture_ux_tutorial_instruction_do")
        view.addSubview(doLabel)
        
        let (doInstructionImages, doInstructionLocalizeKeys, localizedVoiceOverText) = getDoInstructions()
        let doStackView = viewWithInstructionImages(named: doInstructionImages, localizeKeys: doInstructionLocalizeKeys)
        doStackView.accessibilityIdentifier = "doInstructionImages"
        view.addSubview(doStackView)
        
        let doNotLabel = label(withFrame: CGRect(x: 0, y: 0, width: 100, height: 30), localizeKey: "misnap_facial_capture_ux_tutorial_instruction_do_not")
        view.addSubview(doNotLabel)
        
        let (doNotInstructionImages, doNotInstructionLocalizeKeys) = getDoNotInstructions()
        let doNotStackView = viewWithInstructionImages(named: doNotInstructionImages, localizeKeys: doNotInstructionLocalizeKeys)
        doNotStackView.accessibilityIdentifier = "doNotInstructionImages"
        view.addSubview(doNotStackView)
        
        // DO NOT modify this placeholder accessibility label properties or location
        let voiceOverLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        voiceOverLabel.translatesAutoresizingMaskIntoConstraints = false
        voiceOverLabel.accessibilityLabel = localizedVoiceOverText
        view.addSubview(voiceOverLabel)
        
        UIAccessibility.post(notification: .screenChanged, argument: voiceOverLabel)
        
        var topAnchor = view.topAnchor
        if #available(iOS 11.0, *) {
            topAnchor = view.safeAreaLayoutGuide.topAnchor
        }
        
        view.bringSubviewToFront(buttonStackView)
        
        NSLayoutConstraint.activate([
            doLabel.topAnchor.constraint(equalTo: topAnchor),
            doLabel.widthAnchor.constraint(equalToConstant: doLabel.frame.width),
            doLabel.heightAnchor.constraint(equalToConstant: doLabel.frame.height),
            doLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            doStackView.topAnchor.constraint(equalTo: doLabel.bottomAnchor, constant: 5),
            doStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            doNotLabel.topAnchor.constraint(equalTo: doStackView.bottomAnchor, constant: 5),
            doNotLabel.widthAnchor.constraint(equalToConstant: doNotLabel.frame.width),
            doNotLabel.heightAnchor.constraint(equalToConstant: doNotLabel.frame.height),
            doNotLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            doNotStackView.topAnchor.constraint(equalTo: doNotLabel.bottomAnchor, constant: 5),
            doNotStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            voiceOverLabel.topAnchor.constraint(equalTo: doLabel.topAnchor),
            voiceOverLabel.bottomAnchor.constraint(equalTo: doNotStackView.bottomAnchor),
            voiceOverLabel.leftAnchor.constraint(equalTo: view.leftAnchor),
            voiceOverLabel.rightAnchor.constraint(equalTo: view.rightAnchor),
            
            buttonStackView.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -10),
            buttonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonStackView.widthAnchor.constraint(equalToConstant: view.frame.size.width * 0.5),
            buttonStackView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func configureForTimeout() {
        var buttonText = MiSnapFacialCaptureLocalizer.shared.localizedString(for: "misnap_facial_capture_ux_tutorial_button_manual")
        continueButton.setTitle(buttonText, for: .normal)
        continueButton.accessibilityLabel = buttonText
        
        buttonText = MiSnapFacialCaptureLocalizer.shared.localizedString(for: "misnap_facial_capture_ux_tutorial_button_auto")
        retryButton.setTitle(buttonText, for: .normal)
        retryButton.accessibilityLabel = buttonText
        retryButton.isHidden = false
        retryButton.isEnabled = true
        
        let timeUpLabelRect = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40)
        let timeUpLabel = label(withFrame: timeUpLabelRect, localizeKey: "misnap_facial_capture_ux_tutorial_timeout_message_1", fontSize: 19.0, fontWeigth: .regular)
        view.addSubview(timeUpLabel)
        
        let retryLabelRect = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40)
        let retryLabel = label(withFrame: retryLabelRect, localizeKey: "misnap_facial_capture_ux_tutorial_timeout_message_2", fontSize: 19.0, fontWeigth: .regular)
        view.addSubview(retryLabel)
        
        let (timeoutImages, timeoutLocalizeKeys) = getTimeoutInstructions()
        let stackView = viewWithInstructionImages(named: timeoutImages, localizeKeys: timeoutLocalizeKeys)
        stackView.accessibilityIdentifier = "timeoutImages"
        view.addSubview(stackView)
        
        // DO NOT modify this placeholder accessibility label properties or location
        let voiceOverLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        voiceOverLabel.translatesAutoresizingMaskIntoConstraints = false
        voiceOverLabel.accessibilityLabel = MiSnapFacialCaptureLocalizer.shared.localizedString(for: "misnap_facial_capture_ux_tutorial_timeout_voiceover")
        view.addSubview(voiceOverLabel)
                
        UIAccessibility.post(notification: .screenChanged, argument: voiceOverLabel)
        
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            retryLabel.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: -30),
            retryLabel.widthAnchor.constraint(equalToConstant: retryLabel.frame.size.width),
            retryLabel.heightAnchor.constraint(equalToConstant: retryLabel.frame.size.height),
            retryLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            timeUpLabel.bottomAnchor.constraint(equalTo: retryLabel.topAnchor, constant: -30),
            timeUpLabel.widthAnchor.constraint(equalToConstant: timeUpLabel.frame.size.width),
            timeUpLabel.heightAnchor.constraint(equalToConstant: timeUpLabel.frame.size.height),
            timeUpLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            voiceOverLabel.topAnchor.constraint(equalTo: timeUpLabel.topAnchor),
            voiceOverLabel.bottomAnchor.constraint(equalTo: stackView.bottomAnchor),
            voiceOverLabel.leftAnchor.constraint(equalTo: view.leftAnchor),
            voiceOverLabel.rightAnchor.constraint(equalTo: view.rightAnchor),
            
            buttonStackView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 10),
            buttonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonStackView.widthAnchor.constraint(equalToConstant: view.frame.size.width * 0.9),
            buttonStackView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func configureForReview(with image: UIImage?) {
        var buttonText = MiSnapFacialCaptureLocalizer.shared.localizedString(for: "misnap_facial_capture_ux_tutorial_button_continue_review")
        continueButton.setTitle(buttonText, for: .normal)
        continueButton.accessibilityLabel = buttonText
        
        buttonText = MiSnapFacialCaptureLocalizer.shared.localizedString(for: "misnap_facial_capture_ux_tutorial_button_retake")
        retryButton.setTitle(buttonText, for: .normal)
        retryButton.isHidden = false
        retryButton.isEnabled = true
        retryButton.accessibilityLabel = buttonText
        
        let messageLabelRect = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height * 0.07)
        let messageLabel = label(withFrame: messageLabelRect, localizeKey: "misnap_facial_capture_ux_tutorial_review_message", fontSize: 19.0, fontWeigth: .regular)
        view.addSubview(messageLabel)
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height * 0.5))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        
        // DO NOT modify this placeholder accessibility label properties or location
        let voiceOverLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        voiceOverLabel.translatesAutoresizingMaskIntoConstraints = false
        voiceOverLabel.accessibilityLabel = MiSnapFacialCaptureLocalizer.shared.localizedString(for: "misnap_facial_capture_ux_tutorial_review_voiceover")
        view.addSubview(voiceOverLabel)
        
        UIAccessibility.post(notification: .screenChanged, argument: voiceOverLabel)
        
        var topAnchor = view.topAnchor
        if #available(iOS 11.0, *) {
            topAnchor = view.safeAreaLayoutGuide.topAnchor
        }
        
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            messageLabel.widthAnchor.constraint(equalToConstant: messageLabel.frame.width),
            messageLabel.heightAnchor.constraint(equalToConstant: messageLabel.frame.height),
            messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            imageView.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 5),
            imageView.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor, constant: -10),
            imageView.widthAnchor.constraint(equalToConstant: imageView.frame.width),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            voiceOverLabel.topAnchor.constraint(equalTo: messageLabel.topAnchor),
            voiceOverLabel.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            voiceOverLabel.leftAnchor.constraint(equalTo: view.leftAnchor),
            voiceOverLabel.rightAnchor.constraint(equalTo: view.rightAnchor),
            
            buttonStackView.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -10),
            buttonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonStackView.widthAnchor.constraint(equalToConstant: view.frame.size.width * 0.9),
            buttonStackView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func getDoInstructions() -> ([String], [String], String) {
        var images = [
            "misnap_facial_capture_instruction_image_neutral",
            "misnap_facial_capture_instruction_image_oval"
        ]
        
        var localizeKeys = [
            MiSnapFacialCaptureLocalizer.shared.localizedString(for:"misnap_facial_capture_ux_tutorial_instruction_neutral"),
            MiSnapFacialCaptureLocalizer.shared.localizedString(for:"misnap_facial_capture_ux_tutorial_instruction_center")
        ]
        
        var localizedText = ""
        if parameters.mode == .manual || manualSelectionOnly {
            localizedText = MiSnapFacialCaptureLocalizer.shared.localizedString(for: "misnap_facial_capture_ux_tutorial_instruction_voiceover_manual")
        } else if !parameters.selectOnSmile {
            images.append("misnap_facial_capture_instruction_image_neutral")
            localizeKeys.append(MiSnapFacialCaptureLocalizer.shared.localizedString(for:"misnap_facial_capture_ux_tutorial_instruction_hold_still"))
            localizedText = MiSnapFacialCaptureLocalizer.shared.localizedString(for: "misnap_facial_capture_ux_tutorial_instruction_voiceover_auto_countdown")
        } else {
            images.append("misnap_facial_capture_instruction_image_smile")
            localizeKeys.append(MiSnapFacialCaptureLocalizer.shared.localizedString(for:"misnap_facial_capture_ux_tutorial_instruction_smile"))
            localizedText = MiSnapFacialCaptureLocalizer.shared.localizedString(for: "misnap_facial_capture_ux_tutorial_instruction_voiceover_auto_smile")
        }
        
        return (images, localizeKeys, localizedText)
    }
    
    private func getDoNotInstructions() -> ([String], [String]) {
        let images = [
            "misnap_facial_capture_instruction_image_hat",
            "misnap_facial_capture_instruction_image_mask"
        ]
        
        let localizeKeys = [
            MiSnapFacialCaptureLocalizer.shared.localizedString(for:"misnap_facial_capture_ux_tutorial_instruction_no_hat"),
            MiSnapFacialCaptureLocalizer.shared.localizedString(for:"misnap_facial_capture_ux_tutorial_instruction_no_mask")
        ]
        
        return (images, localizeKeys)
    }
    
    private func getTimeoutInstructions() -> ([String], [String]) {
        var images: [String] = []
        
        if parameters.selectOnSmile {
            images.append("misnap_facial_capture_instruction_image_smile")
        } else {
            images.append("misnap_facial_capture_instruction_image_neutral")
        }
        
        images.append("misnap_facial_capture_instruction_image_neutral_manual")
        
        return (images, ["", ""])
    }
    
    private func label(withFrame frame: CGRect, localizeKey: String, fontSize: CGFloat = 17.0, fontWeigth: UIFont.Weight = .bold) -> UILabel {
        let label = UILabel(frame: frame)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = MiSnapFacialCaptureLocalizer.shared.localizedString(for: localizeKey)
        label.textAlignment = .center
        label.font = .systemFont(ofSize: fontSize, weight: fontWeigth)
        label.isAccessibilityElement = false
        return label
    }
    
    private func viewWithInstructionImage(named name: String, localizeKey: String) -> UIView {
        // Get screen size and aspect ratio
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let screenAr = screenWidth > screenHeight ? screenWidth / screenHeight : screenHeight / screenWidth
        
        // Get aspect ratio of an instructional image
        let ar: CGFloat = 476 / 282.0
        // Instructional image width should be 26% of a screen width
        let width: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? screenWidth * 0.21 : screenAr > 1.78 ? screenWidth * 0.26 : screenWidth * 0.23
        // Instructional image height is calculated based on its width and aspect ratio
        let height: CGFloat = width * ar
        
        let labelHeight = height * 0.5
        
        let spacing: CGFloat = 0.0
        
        // Container width should be 15% bigger than instructinal image width
        let containerWidth: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? width * 1.35 : screenAr > 1.78 ? width * 1.15 : width * 1.3
        // Container height should be instructional image height + label height + spacing between them
        let containerHeight: CGFloat = height + labelHeight + spacing
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: containerWidth, height: containerHeight))
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .clear
        containerView.isAccessibilityElement = false
        containerView.accessibilityElementsHidden = true
        
        let isManual = name.contains("_neutral_manual")
        let imageName = name.replacingOccurrences(of: "_neutral_manual", with: "_neutral")
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: imageName)
        imageView.contentMode = .scaleAspectFit
        
        var manualImageView: UIImageView?
        if isManual {
            let manualAr: CGFloat = 179 / 167.0
            let manualWidth = width * 0.65
            manualImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: manualWidth, height: manualWidth * manualAr))
            guard let manualImageView = manualImageView else { return UIView() }
            manualImageView.translatesAutoresizingMaskIntoConstraints = false
            manualImageView.image = UIImage(named: "misnap_facial_capture_instruction_manual_with_finger")
            manualImageView.contentMode = .scaleAspectFit
            imageView.addSubview(manualImageView)
        }
        
        let label = UITextView(frame: CGRect(x: 0, y: 0, width: containerWidth, height: labelHeight))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.isScrollEnabled = false
        label.isEditable = false
        label.isSelectable = false
        label.showsHorizontalScrollIndicator = false
        label.showsVerticalScrollIndicator = false
        label.backgroundColor = .clear
        label.text = MiSnapFacialCaptureLocalizer.shared.localizedString(for: localizeKey)
        label.font = bestFontSizeForInstruction(in: label.frame)
        label.textContainer.lineFragmentPadding = 0
        
        containerView.addSubview(imageView)
        containerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: imageView.frame.width),
            imageView.heightAnchor.constraint(equalToConstant: imageView.frame.height),
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            label.widthAnchor.constraint(equalTo: containerView.widthAnchor),
            label.heightAnchor.constraint(equalToConstant: label.frame.height),
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: spacing),
            label.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
        
        if isManual, let manualImageView = manualImageView {
            NSLayoutConstraint.activate([
                manualImageView.widthAnchor.constraint(equalToConstant: manualImageView.frame.width),
                manualImageView.heightAnchor.constraint(equalToConstant: manualImageView.frame.height),
                manualImageView.centerYAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -10),
                manualImageView.centerXAnchor.constraint(equalTo: imageView.rightAnchor, constant: -10)
            ])
        }
        
        return containerView
    }
    
    private func viewWithInstructionImages(named names: [String], localizeKeys: [String]) -> UIView {
        guard names.count == localizeKeys.count else { return UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0)) }
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.distribution = .fill
        
        let multiplier: CGFloat = names.count == 2 ? 1.5 : 1.0
        var stackViewWidth: CGFloat = 0
        var stackViewHeight: CGFloat = 0
        
        for idx in names.indices {
            let containerView = viewWithInstructionImage(named: names[idx], localizeKey: localizeKeys[idx])
            stackViewWidth += containerView.frame.width * multiplier
            stackViewHeight = containerView.frame.height
            
            stackView.addArrangedSubview(containerView)
            
            NSLayoutConstraint.activate([
                containerView.widthAnchor.constraint(equalToConstant: containerView.frame.width * multiplier),
                containerView.heightAnchor.constraint(equalToConstant: containerView.frame.height)
            ])
        }
        
        NSLayoutConstraint.activate([
            stackView.widthAnchor.constraint(equalToConstant: stackViewWidth),
            stackView.heightAnchor.constraint(equalToConstant: stackViewHeight)
        ])
        
        return stackView
    }
    
    private func bestFontSizeForInstruction(in bounds: CGRect) -> UIFont {
        var instructionStrings = [
            MiSnapFacialCaptureLocalizer.shared.localizedString(for:"misnap_facial_capture_ux_tutorial_instruction_neutral"),
            MiSnapFacialCaptureLocalizer.shared.localizedString(for:"misnap_facial_capture_ux_tutorial_instruction_center"),
            MiSnapFacialCaptureLocalizer.shared.localizedString(for:"misnap_facial_capture_ux_tutorial_instruction_no_hat"),
            MiSnapFacialCaptureLocalizer.shared.localizedString(for:"misnap_facial_capture_ux_tutorial_instruction_no_mask")
        ]
        
        if parameters.mode == .manual || manualSelectionOnly || !parameters.selectOnSmile {
            instructionStrings.append(MiSnapFacialCaptureLocalizer.shared.localizedString(for:"misnap_facial_capture_ux_tutorial_instruction_hold_still"))
        } else {
            instructionStrings.append(MiSnapFacialCaptureLocalizer.shared.localizedString(for:"misnap_facial_capture_ux_tutorial_instruction_smile"))
        }
        
        var maxLengthString = ""
        for string in instructionStrings where string.count > maxLengthString.count {
            maxLengthString = string
        }
        
        let font = UIFont.systemFont(ofSize: 50.0, weight: .regular)
        return UIFont.bestFittingFont(for: maxLengthString, in: bounds, fontDescriptor: font.fontDescriptor)
    }
}

extension UIFont {
    /**
     Will return the best font conforming to the descriptor which will fit in the provided bounds.
     */
    static func bestFittingFontSize(for text: String, in bounds: CGRect, fontDescriptor: UIFontDescriptor, additionalAttributes: [NSAttributedString.Key: Any]? = nil) -> CGFloat {
        let constrainingDimension = min(bounds.width, bounds.height)
        let properBounds = CGRect(origin: .zero, size: bounds.size)
        var attributes = additionalAttributes ?? [:]
        
        let infiniteBounds = CGSize(width: bounds.width, height: CGFloat.infinity)
        var bestFontSize: CGFloat = constrainingDimension
        
        for fontSize in stride(from: bestFontSize, through: 0, by: -1) {
            let newFont = UIFont(descriptor: fontDescriptor, size: fontSize)
            attributes[.font] = newFont
            
            let currentFrame = text.boundingRect(with: infiniteBounds, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attributes, context: nil)
            
            if properBounds.contains(currentFrame) {
                bestFontSize = fontSize
                break
            }
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            bestFontSize -= 5.0
        }
        return bestFontSize
    }
    
    static func bestFittingFont(for text: String, in bounds: CGRect, fontDescriptor: UIFontDescriptor, additionalAttributes: [NSAttributedString.Key: Any]? = nil) -> UIFont {
        let bestSize = bestFittingFontSize(for: text, in: bounds, fontDescriptor: fontDescriptor, additionalAttributes: additionalAttributes)
        return UIFont(descriptor: fontDescriptor, size: bestSize)
    }
}
