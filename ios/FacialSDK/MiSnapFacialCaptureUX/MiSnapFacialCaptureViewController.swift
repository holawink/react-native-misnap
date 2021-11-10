//
//  MiSnapFacialCaptureViewController.swift
//  MiSnapFacialCaptureSampleApp
//
//  Created by Stas Tsuprenko on 6/12/20.
//  Copyright © 2020 Mitek Systems Inc. All rights reserved.
//

import UIKit
import MiSnapFacialCapture

private enum MiSnapFacialCaptureViewControllerDismissalReason: String, Equatable {
    case cancelled, succeeded
}

public enum MiSnapFacialCaptureReview: String, Equatable {
    case manualOnly, autoOnly, autoAndManual, none
}

protocol MiSnapFacialCaptureViewControllerDelegate: NSObject {
    func miSnapFacialCaptureSuccess(_ results: MiSnapFacialCaptureResults)
    func miSnapFacialCaptureCancelled(_ results: MiSnapFacialCaptureResults)
    func miSnapFacialCaptureDidFinishRecordingVideo(_ videoData: Data?)
    func miSnapFacialCaptureDidFinishSuccessAnimation()
}

extension MiSnapFacialCaptureViewControllerDelegate {
    func miSnapFacialCaptureDidFinishSuccessAnimation() {}
    func miSnapFacialCaptureDidFinishRecordingVideo(_ videoData: Data?) {}
}

class MiSnapFacialCaptureViewController: UIViewController {
    private(set) var parameters: MiSnapFacialCaptureParameters!
    private weak var delegate: MiSnapFacialCaptureViewControllerDelegate?
    private let shouldAutoDissmiss: Bool!
    private let review: MiSnapFacialCaptureReview!
    private let countdownStyle: MiSnapFacialCaptureCountdownStyle!
    
    private var overlayView: MiSnapFacialCaptureOverlayView?
    private var analyzer: MiSnapFacialCaptureAnalyzer?
    private var cameraView: MiSnapFacialCaptureCamera?
            
    private var containerView: UIView!
    private var currentChildVC: UIViewController?
    
    private var sessionTimer: Timer?
    private var dismissalReason: MiSnapFacialCaptureViewControllerDismissalReason = .cancelled
    
    private var manualSelectionOnly: Bool = false
    
    private var countdownTimer: Timer?
    private var countdownCounter: Int = 0
    
    private var results: MiSnapFacialCaptureResults = MiSnapFacialCaptureResults()
    private var videoData: Data?
    
    private var shouldShowInstructionTutorial: Bool {
        // Always show instruction tutorial for now
        return true
    }
    
    required init?(coder: NSCoder) {
        fatalError("MiSnapFacialCaptureViewController.init(coder:) has not been implemented")
    }
    
    init(with parameters: MiSnapFacialCaptureParameters, delegate: MiSnapFacialCaptureViewControllerDelegate, countdownStyle: MiSnapFacialCaptureCountdownStyle = .burndUp, shouldAutoDissmiss: Bool = true, review: MiSnapFacialCaptureReview = .manualOnly) {
        self.parameters = parameters
        guard let _ = self.parameters else { fatalError("Parameters are nil") }
        self.delegate = delegate
        self.countdownStyle = countdownStyle
        self.shouldAutoDissmiss = shouldAutoDissmiss
        self.review = review
        super.init(nibName: nil, bundle: nil)
    }
    
    public func set(delegate: MiSnapFacialCaptureViewControllerDelegate?) {
        self.delegate = delegate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.shared.isIdleTimerDisabled = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(sessionWasInterrupted(_:)), name: .AVCaptureSessionWasInterrupted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sessionInterruptionEnded), name: .AVCaptureSessionInterruptionEnded, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureOverlayView()
        
        configureAnalyzer()
        
        configureContainerView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if shouldShowInstructionTutorial {
            presentTutorial(for: .instruction)
        } else {
            start()
        }
    }
    
    private func start() {
        startSessionTimer()
        #if targetEnvironment(simulator)
        didFinishConfiguringSession()
        #else
        if let cameraView = cameraView, cameraView.isConfigured {
            didFinishConfiguringSession()
        } else {
            configureCameraView()
        }
        #endif
        analyzer?.resume()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        containerView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        if let currentChildVC = currentChildVC {
            currentChildVC.viewWillTransition(to: size, with: coordinator)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    private func configureOverlayView() {
        overlayView = MiSnapFacialCaptureOverlayView(with: parameters, delegate: self, frame: view.frame)
        guard let overlayView = overlayView else { fatalError("Couldn't initialize overlay view") }
        overlayView.alpha = 0.0
        
        view.addSubview(overlayView)
        
        NSLayoutConstraint.activate([
            overlayView.leftAnchor.constraint(equalTo: view.leftAnchor),
            overlayView.rightAnchor.constraint(equalTo: view.rightAnchor),
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func configureAnalyzer() {
        analyzer = MiSnapFacialCaptureAnalyzer.init(parameters: parameters)
        guard let analyzer = analyzer else { fatalError("Couldn't initialize analyzer") }
        analyzer.delegate = self
    }
    
    private func configureContainerView() {
        containerView = UIView.init(frame: view.frame)
        guard let overlayView = overlayView else { return }
        view.insertSubview(containerView, belowSubview: overlayView)
    }
    
    private func configureCameraView() {
        cameraView = MiSnapFacialCaptureCamera.init(preset: .hd1280x720, format: Int(kCVPixelFormatType_32BGRA), position: .front, frame: view.frame)
        guard let cameraView = cameraView else { fatalError("Couldn't initialize camera view") }
        cameraView.parameters = self.parameters.cameraParameters
        cameraView.delegate = self
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        
        guard let overlayView = overlayView else { return }
        view.insertSubview(cameraView, belowSubview: overlayView)
        
        NSLayoutConstraint.activate([
            cameraView.leftAnchor.constraint(equalTo: view.leftAnchor),
            cameraView.rightAnchor.constraint(equalTo: view.rightAnchor),
            cameraView.topAnchor.constraint(equalTo: view.topAnchor),
            cameraView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    deinit {
        print("MiSnapFacialCaptureViewController is deinitialized")
    }
}

extension MiSnapFacialCaptureViewController {
    private func startSessionTimer() {
        if sessionTimer == nil {
            if parameters.mode == .manual && parameters.cameraParameters.recordVideo {
                sessionTimer = Timer.scheduledTimer(timeInterval: 45,
                                                    target: self,
                                                    selector: #selector(timeoutOccurred),
                                                    userInfo: nil,
                                                    repeats: false)
            } else if parameters.mode == .auto {
                sessionTimer = Timer.scheduledTimer(timeInterval: TimeInterval(parameters.timeout),
                                                    target: self,
                                                    selector: #selector(timeoutOccurred),
                                                    userInfo: nil,
                                                    repeats: false)
            }
        }
    }
    
    private func invalidateSessionTimer() {
        if let timer = sessionTimer {
            timer.invalidate()
            sessionTimer = nil
        }
    }
    
    @objc private func timeoutOccurred() {
        invalidateSessionTimer()
        invalidateCountdownTimer()
        presentTutorial(for: .timeout)
    }
    
    private func presentTutorial(for tutorialMode: MiSnapFacialCaptureTuturialMode) {
        invalidateSessionTimer()
        invalidateCountdownTimer()
        
        let tutorialVC = MiSnapFacialCaptureTutorialViewController(for: tutorialMode,
                                                                      delegate: self,
                                                                      parameters: parameters,
                                                                      manualOnly: manualSelectionOnly,
                                                                      image: results.selectedImage)
        analyzer?.pause(for: tutorialMode)
        
        presentVC(tutorialVC)
    }
    
    private func shouldStartTimeoutTimer(for highestPriorityStatus: MiSnapFacialCaptureStatus) -> Bool {
        if  highestPriorityStatus != .faceNotFound &&
            highestPriorityStatus != .tooFar &&
            highestPriorityStatus != .tooClose &&
            highestPriorityStatus != .countdown &&
            parameters?.mode == .auto &&
            sessionTimer == nil {
            return true
        }
        return false
    }
    
    private func playShutterSound() {
        AudioServicesPlaySystemSound(1108)
    }
    
    private func shutdown(reason: MiSnapFacialCaptureViewControllerDismissalReason = .succeeded) {
        view.backgroundColor = .black
        MiSnapFacialCaptureLocalizer.destroyShared()
        invalidateSessionTimer()
        invalidateCountdownTimer()
        
        if !parameters.cameraParameters.recordVideo || reason == .cancelled {
            cameraView?.discardRecording()
            removeCameraView()
        }
        cameraView?.stop()
        cameraView?.shutdown()
        analyzer?.stop()
        analyzer?.delegate = nil
        analyzer = nil
        
        overlayView?.set(delegate: nil)
        NotificationCenter.default.removeObserver(self)
    }
    
    private func removeCameraView() {
        cameraView?.delegate = nil
        cameraView?.removeFromSuperview()
    }
    
    @objc private func sessionWasInterrupted(_ notification: Notification) {
        invalidateSessionTimer()
        invalidateCountdownTimer()
        analyzer?.pause()
        
        cameraView?.discardRecording()
        
        guard let dict = notification.userInfo,
              let reasonInt = dict[AVCaptureSessionInterruptionReasonKey] as? Int,
              let reason = AVCaptureSession.InterruptionReason(rawValue: reasonInt) else { return }
        
        switch reason {
        case .videoDeviceNotAvailableInBackground:
            overlayView?.addInterruptionView(withMessage: MiSnapFacialCaptureLocalizer.shared.localizedString(for: ""))
        case .audioDeviceInUseByAnotherClient:
            overlayView?.addInterruptionView(withMessage: MiSnapFacialCaptureLocalizer.shared.localizedString(for: "misnap_facial_capture_ux_interruption_microphone_in_use"))
        case .videoDeviceInUseByAnotherClient:
            overlayView?.addInterruptionView(withMessage: MiSnapFacialCaptureLocalizer.shared.localizedString(for: "misnap_facial_capture_ux_interruption_camera_in_use"))
        case .videoDeviceNotAvailableWithMultipleForegroundApps:
            overlayView?.addInterruptionView(withMessage: MiSnapFacialCaptureLocalizer.shared.localizedString(for: "misnap_facial_capture_ux_interruption_multiple_foreground_apps"))
        default: break
        }
    }
    
    @objc private func sessionInterruptionEnded() {
        startSessionTimer()
        overlayView?.removeInterruptionView()
        cameraView?.start()
        analyzer?.resume()
    }
}

extension MiSnapFacialCaptureViewController {
    // MARK: Child view controller related methods
    
    private func presentVC(_ vc: UIViewController) {
        guard let containerView = containerView else { return }
        view.bringSubviewToFront(containerView)
        view.accessibilityElements = [containerView]
        
        if let currentChildVC = currentChildVC {
            move(from: currentChildVC, to: vc)
        } else {
            presentAsChildViewController(vc)
        }
        
        currentChildVC = vc
    }
    
    private func presentAsChildViewController(_ vc: UIViewController) {
        vc.navigationController?.navigationBar.isHidden = true
        vc.modalPresentationStyle = .fullScreen
        
        addChild(vc)
        containerView.addSubview(vc.view)
        vc.view.frame = containerView.bounds
        vc.didMove(toParent: self)
    }
    
    private func move(from fromVC: UIViewController, to toVC: UIViewController) {
        toVC.navigationController?.navigationBar.isHidden = true
        toVC.modalPresentationStyle = .fullScreen
        
        toVC.view.frame = fromVC.view.frame
        addChild(toVC)
        fromVC.willMove(toParent: nil)
        
        transition(from: fromVC, to: toVC, duration: 0.5, options: .transitionCrossDissolve, animations: nil) { (finished) in
            if finished {
                toVC.didMove(toParent: self)
                fromVC.removeFromParent()
            }
        }
    }
    
    private func dismissChildViewController(animated: Bool) {
        guard let overlayView = overlayView else { return }
        view.accessibilityElements = [overlayView]
        if let currentChildVC = currentChildVC {
            currentChildVC.willMove(toParent: nil)
            currentChildVC.view.removeFromSuperview()
            currentChildVC.removeFromParent()
            
            if let tutorialVC = currentChildVC as? MiSnapFacialCaptureTutorialViewController {
                tutorialVC.set(delegate: nil)
            }
            
            self.currentChildVC = nil
            
            guard let containerView = self.containerView else { return }
            
            if animated {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) { [weak self] in
                    self?.view.sendSubviewToBack(containerView)
                }
            } else {
                view.sendSubviewToBack(containerView)
            }
        }
    }
    
    private func dismiss(animated: Bool, reason: MiSnapFacialCaptureViewControllerDismissalReason) {
        overlayView?.removeFromSuperview()
        
        dismissChildViewController(animated: animated)
        
        if shouldAutoDissmiss {
            if let navigationController = self.navigationController {
                navigationController.popViewController(animated: animated)
            } else {
                dismiss(animated: animated, completion: nil)
            }
        }
        
        switch reason {
        case .succeeded: delegate?.miSnapFacialCaptureDidFinishSuccessAnimation()
        default: break
        }
        
    }
}

extension MiSnapFacialCaptureViewController: MiSnapFacialCaptureOverlayViewDelegate {
    // MARK: MiSnapFacialCaptureOverlayViewDelegate callbacks
    
    func cancelButtonAction() {
        analyzer?.cancel()
        shutdown(reason: .cancelled)
        dismiss(animated: true, reason: .cancelled)
    }
    
    func helpButtonAction() {
        presentTutorial(for: .help)
    }
    
    func manualSelectionButtonAction() {
        analyzer?.selectFrame()
    }
}

extension MiSnapFacialCaptureViewController: MiSnapFacialCaptureTutorialViewControllerDelegate {
    // MARK: MiSnapFacialCaptureTutorialViewControllerDelegate callbacks
    
    func tutorialCancelButtonAction() {
        analyzer?.cancel()
        shutdown(reason: .cancelled)
        dismiss(animated: false, reason: .cancelled)
    }
    
    func tutorialContinueButtonAction(for tutorialMode: MiSnapFacialCaptureTuturialMode) {
        if tutorialMode == .review {
            delegate?.miSnapFacialCaptureSuccess(results)
            delegate?.miSnapFacialCaptureDidFinishRecordingVideo(videoData)
            removeCameraView()
            shutdown()
            dismiss(animated: false, reason: .succeeded)
        } else {
            if tutorialMode == .timeout {
                parameters?.mode = .manual
                overlayView?.update(parameters.mode)
                analyzer?.update(parameters.mode)
                #if targetEnvironment(simulator)
                overlayView?.manageManualButton(for: .none)
                #endif
            }
            dismissChildViewController(animated: true)
            start()
        }
    }
    
    func tutorialRetryButtonAction(for tutorialMode: MiSnapFacialCaptureTuturialMode) {
        dismissChildViewController(animated: true)
        start()
    }
}

extension MiSnapFacialCaptureViewController: MiSnapFacialCaptureCameraDelegate {
    // MARK: MiSnapFacialCaptureCameraDelegate callbacks
    
    func didFinishConfiguringSession() {
        DispatchQueue.main.async { [unowned self] in
            self.cameraView?.start()
            
            UIView.animate(withDuration: 0.5) {
                self.overlayView?.alpha = 1.0
            }
            
            if self.manualSelectionOnly, !self.shouldShowInstructionTutorial {
                let message = "Current iOS version doesn't support Auto mode with real-time guidance.\nCenter your face in the oval and tap Manual button when ready"
                let alert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertController.Style.alert)
                let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func didReceive(_ sampleBuffer: CMSampleBuffer?) {
        analyzer?.analyze(sampleBuffer)
    }
    
    func didFinishRecordingVideo(_ videoData: Data?) {
        if review == .autoAndManual || (review == .manualOnly && parameters.mode == .manual) || (review == .autoOnly && parameters.mode == .auto) {
            self.videoData = videoData
        } else {
            delegate?.miSnapFacialCaptureDidFinishRecordingVideo(videoData)
            DispatchQueue.main.async { [unowned self] in
                self.removeCameraView()
            }
        }
    }
}

extension MiSnapFacialCaptureViewController {
    // MARK: MiSnapFacialCaptureCamera permissions and free disc space
    
    public func checkCameraPermission(handler: @escaping (Bool) -> Void) {
        MiSnapFacialCaptureCamera.checkPermission(handler)
    }
    
    public func checkMicrophonePermission(handler: @escaping (Bool) -> Void) {
        MiSnapFacialCaptureCamera.checkMicrophonePermission(handler)
    }
    
    public func hasMinDiskSpace(_ minDiskSpace: Int) -> Bool {
        guard let documentsDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else { return false }
        
        do {
            let dict = try FileManager.default.attributesOfFileSystem(forPath: documentsDir)
            guard let totalFreeSpace = dict[.systemFreeSize] as? UInt64 else { return false }
            let totalFreeSpaceMb = totalFreeSpace / (1024 * 1024)
            return totalFreeSpaceMb >= minDiskSpace
        } catch {
            return false
        }
    }
}

extension MiSnapFacialCaptureViewController: MiSnapFacialCaptureAnalyzerDelegate {
    // MARK: MiSnapFacialCaptureAnalyzerDelegate callbacks
    
    func detectionResults(_ results: MiSnapFacialCaptureResults!) {
        overlayView?.update(with: results)
        
        if results.highestPriorityStatus != .countdown {
            invalidateCountdownTimer()
        }
        
        if shouldStartTimeoutTimer(for: results.highestPriorityStatus) {
            startSessionTimer()
        }
    }
    
    func detectionSuccess(_ results: MiSnapFacialCaptureResults!) {
        UIAccessibility.post(notification: .announcement, argument: MiSnapFacialCaptureLocalizer.shared.localizedString(for: "misnap_facial_capture_ux_success"))
        cameraView?.stop()
        invalidateSessionTimer()
        invalidateCountdownTimer()
        playShutterSound()
        overlayView?.runSuccessAnimation()
        
        if review == .autoAndManual || (review == .manualOnly && parameters.mode == .manual) || (review == .autoOnly && parameters.mode == .auto) {
            self.results = results
            // Present review screen after termination delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                self?.overlayView?.removeSuccessAnimation()
                self?.presentTutorial(for: .review)
            }
        } else {
            // Send success results immediately
            delegate?.miSnapFacialCaptureSuccess(results)
            shutdown()
            // Dismiss after termination delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                self?.dismiss(animated: false, reason: .succeeded)
            }
        }
    }
    
    func detectionCancelled(_ results: MiSnapFacialCaptureResults!) {
        delegate?.miSnapFacialCaptureCancelled(results)
    }
    
    func manualOnly() {
        overlayView?.manageManualOnly()
        manualSelectionOnly = true
    }
    
    func startCountdown() {
        invalidateSessionTimer()
        if countdownTimer == nil {
            overlayView?.addCountdownTimer(with: countdownStyle)
            let timeInterval = TimeInterval(parameters.countdownTime) / 3.0
            countdownCounter = 3
            countdownTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(countdownTimerAction), userInfo: nil, repeats: true)
        }
    }

    private func invalidateCountdownTimer() {
        if let timer = countdownTimer {
            timer.invalidate()
            countdownTimer = nil
            overlayView?.removeCountdownTimer()
        }
    }

    @objc private func countdownTimerAction() {
        if countdownCounter == 0 {
            invalidateCountdownTimer()
            analyzer?.selectFrame()
        } else {
            overlayView?.updateCountdownTimer(with: countdownCounter)
            countdownCounter -= 1
        }
    }
}
