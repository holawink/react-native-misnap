//
//  MainViewController.swift
//  MainViewController
//
//  Created by Joseph Ramirez on 11/3/21.
//  Copyright © 2021 Facebook. All rights reserved.
//

import Foundation

import UIKit
import MiSnapFacialCapture

@objc open class MainViewController: UIViewController {
    
    @IBOutlet weak var launchButton: UIButton!
    var selectOnSmileSwitch: UISwitch!
    var countdownStyleSegmentedControl: UISegmentedControl!
    var reviewSegmentedControl: UISegmentedControl!
    var recordVideoSwitch: UISwitch!
    var recordAudioSwitch: UISwitch!
    var verticalStackView: UIStackView!
    
    var results: MiSnapFacialCaptureResults?
    var miSnapFacialCaptureVC: MiSnapFacialCaptureViewController?

    override open func viewDidLoad() {
        super.viewDidLoad()
        
        print("MiSnapFacialCapture v\(MiSnapFacialCapture.version())")
        launchButton.setTitle("Launch MiSnapFacialCapture v\(MiSnapFacialCapture.version())", for: .normal)
        
        configureSubviews()
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        miSnapFacialCaptureVC = nil
        
        if let results = results {
            // let resultVC = ResultsViewController.init(with: results)
            // resultVC.modalTransitionStyle = .crossDissolve
            // resultVC.modalPresentationStyle = .fullScreen
            
            // presentVC(resultVC)
            
            // self.results = nil
        }
    }
    
    override open var prefersStatusBarHidden: Bool {
        return true
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    // posible to run logic
    @objc open func launchButtonAction(_ sender: Any) {
        let parameters = MiSnapFacialCaptureParameters()
        //parameters.countdownTime = 3
        //parameters.mode = .manual
        //parameters.timeout = 3
        //parameters.roll = 800
        //parameters.pitch = 1000
        //parameters.yaw = 1000
        
        // Uncomment line below to see face landmarks for debugging purposes
        //parameters.highlightLandmarks = true
        
        parameters.selectOnSmile = selectOnSmileSwitch.isOn
                
        parameters.cameraParameters.recordVideo = recordVideoSwitch.isOn
        parameters.cameraParameters.recordAudio = recordAudioSwitch.isOn
        
        // Uncomment line below if you don't want to display recording UI to a user
        // Note, this parameters is only used when recordVideo is set to `true`
        //parameters.cameraParameters.showRecordingUI = false
        
        // Note, that "countdownStyle" is active only when "parameters.selectOnSmile" is "false" (default)
        miSnapFacialCaptureVC = MiSnapFacialCaptureViewController(with: parameters, delegate: self, countdownStyle: styleFromSegmentedControl(), review: reviewFromSegmentedControl())
        guard let miSnapFacialCaptureVC = miSnapFacialCaptureVC else { fatalError("Could not initialize MiSnapFacialCaptureViewController") }
        miSnapFacialCaptureVC.modalPresentationStyle = .fullScreen
        miSnapFacialCaptureVC.modalTransitionStyle = .crossDissolve
        
        presentFacialCaptureVC(miSnapFacialCaptureVC)
    }
    
    func presentFacialCaptureVC(_ vc: MiSnapFacialCaptureViewController) {
        // Set modalPresentationStyle to fullScreen explicitly to avoid undefined behavior on iOS 13 or newer
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
        
        // It's recommended to check that there's at least 20 MB of free disc space available before starting a session when video recording is enabled
        let minDiskSpace = 20
        if vc.parameters.cameraParameters.recordVideo && !vc.hasMinDiskSpace(minDiskSpace) {
            presentAlert(withTitle: "Not Enough Space", message: "Please, delete old/unused files to have at least \(minDiskSpace) MB of free space")
            return
        }
        
        // Check camera permission before presentign a view controller to avoid undefined behavior
        vc.checkCameraPermission { [unowned self] (granted) in
            if !granted {
                var message = "Camera permission is required to capture your documents."
                if vc.parameters.cameraParameters.recordVideo {
                    message = "Camera permission is required to capture your documents and record videos of the entire process as required by a country regulation."
                }
                self.presentPermissionAlert(withTitle: "Camera Permission Denied", message: "\(message)\nPlease select \"Open Settings\" option and enable Camera permission")
                return
            }
            
            // Check microphone permission before presentign a view controller to avoid undefined behavior when video with audio recording is enabled
            if vc.parameters.cameraParameters.recordVideo && vc.parameters.cameraParameters.recordAudio {
                vc.checkMicrophonePermission { [unowned self] (granted) in
                    if !granted {
                        let message = "Microphone permission is required to record audio as required by a country regulation."
                        self.presentPermissionAlert(withTitle: "Microphone Permission Denied", message: "\(message)\nPlease select \"Open Settings\" option and enable Microphone permission")
                        return
                    }
                    
                    DispatchQueue.main.async { [unowned self] in
                        self.present(vc, animated: true, completion: nil)
                    }
                }
            } else {
                DispatchQueue.main.async { [unowned self] in
                    self.present(vc, animated: true, completion: nil)
                }
            }
        }
    }
    
    func presentVC(_ vc: UIViewController) {
        if let navigationController = navigationController {
            navigationController.pushViewController(vc, animated: true)
        } else {
            present(vc, animated: true, completion: nil)
        }
    }
    
    func presentAlert(withTitle title: String, message: String) {
        DispatchQueue.main.async { [unowned self] in
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(ok)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func presentPermissionAlert(withTitle title: String, message: String) {
        DispatchQueue.main.async { [unowned self] in
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            let openSettings = UIAlertAction(title: "Open Settings", style: .cancel) { _ in
                // if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                //     UIApplication.shared.open(url, options: [:], completionHandler: nil)
                // }
            }
            alert.addAction(cancel)
            alert.addAction(openSettings)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func configureSubviews() {
        verticalStackView = UIStackView()
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 10
        verticalStackView.distribution = .fill
        
        selectOnSmileSwitch = getSwitch(isOn: false, selector: #selector(selectOnSmileSwitchAction(_:)))
        
        countdownStyleSegmentedControl = UISegmentedControl(items: ["Burn Up", "Infinity", "Pulsate", "Simple"])
        countdownStyleSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        countdownStyleSegmentedControl.selectedSegmentIndex = 0
        
        reviewSegmentedControl = UISegmentedControl(items: ["Manual", "Auto", "Both", "None"])
        reviewSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        reviewSegmentedControl.selectedSegmentIndex = 0
        
        recordVideoSwitch = getSwitch(isOn: false, selector: #selector(recordVideoSwitchChanged(_:)))
        recordAudioSwitch = getSwitch(isOn: false)
        
        add(view: selectOnSmileSwitch, withTitle: "Take Selfie On Smile", widthRatio: 0.8)
        add(view: countdownStyleSegmentedControl, withTitle: "Style")
        add(view: reviewSegmentedControl, withTitle: "Review")
        add(view: recordVideoSwitch, withTitle: "Record Video")
        
        view.addSubview(verticalStackView)
        
        NSLayoutConstraint.activate([
            countdownStyleSegmentedControl.widthAnchor.constraint(equalToConstant: 240),
            
            reviewSegmentedControl.widthAnchor.constraint(equalToConstant: 240),
                        
            verticalStackView.topAnchor.constraint(equalTo: launchButton.bottomAnchor, constant: 20),
            verticalStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            verticalStackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.95)
        ])
    }
    
    func getSwitch(isOn: Bool, selector: Selector? = nil) -> UISwitch {
        let switchView = UISwitch()
        switchView.translatesAutoresizingMaskIntoConstraints = false
        if let selector = selector {
            switchView.addTarget(self, action: selector, for: .valueChanged)
        }
        switchView.isOn = isOn
        return switchView
    }
    
    func add(view: UIView, withTitle title: String, widthRatio: CGFloat? = nil, at index: Int? = nil) {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 32))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.backgroundColor = .clear
        label.text = title
        
        let horizontalStackView = UIStackView(arrangedSubviews: [label, view])
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView.axis = .horizontal
        horizontalStackView.spacing = 5
        horizontalStackView.distribution = .equalSpacing
        
        if let i = index {
            verticalStackView.insertArrangedSubview(horizontalStackView, at: i)
        } else {
            verticalStackView.addArrangedSubview(horizontalStackView)
        }
        
        NSLayoutConstraint.activate([
            label.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        guard let ratio = widthRatio else { return }
        
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalTo: horizontalStackView.widthAnchor, multiplier: ratio)
        ])
    }
    
    @objc func selectOnSmileSwitchAction(_ switchView: UISwitch) {
        var i = -1
        for (index, subview) in verticalStackView.arrangedSubviews.enumerated() {
            if switchView.isDescendant(of: subview) {
                i = index
                break
            }
        }
        
        guard i != -1 else { return }
        
        if switchView.isOn {
            if let v = verticalStackView.arrangedSubviews[i + 1] as? UIStackView {
                v.removeFromSuperview()
            }
        } else {
            add(view: countdownStyleSegmentedControl, withTitle: "Style", at: i + 1)
        }
    }
    
    @objc func recordVideoSwitchChanged(_ switchView: UISwitch) {
        var i = -1
        for (index, subview) in verticalStackView.arrangedSubviews.enumerated() {
            if switchView.isDescendant(of: subview) {
                i = index
                break
            }
        }
        
        guard i != -1 else { return }
        
        if switchView.isOn {
            add(view: recordAudioSwitch, withTitle: "Record Audio", at: i + 1)
        } else {
            recordAudioSwitch.isOn = false
            if let v = verticalStackView.arrangedSubviews[i + 1] as? UIStackView {
                v.removeFromSuperview()
            }
        }
    }
    
    func styleFromSegmentedControl() -> MiSnapFacialCaptureCountdownStyle {
        switch countdownStyleSegmentedControl.selectedSegmentIndex {
        case 0: return .burndUp
        case 1: return .infinity
        case 2: return .pulsate
        case 3: return .simple
        default: return .simple
        }
    }
    
    func reviewFromSegmentedControl() -> MiSnapFacialCaptureReview {
        switch reviewSegmentedControl.selectedSegmentIndex {
        case 0: return .manualOnly
        case 1: return .autoOnly
        case 2: return .autoAndManual
        case 3: return .none
        default: return .manualOnly
        }
    }
}

extension MainViewController: MiSnapFacialCaptureViewControllerDelegate {
    // MARK: MiSnapFacialCaptureViewControllerDelegate callbacks
    
    func miSnapFacialCaptureSuccess(_ results: MiSnapFacialCaptureResults) {
        self.results = results
        print("MIBI Data:\n\(results.mibiDataString ?? "")")
    }
    
    func miSnapFacialCaptureCancelled(_ results: MiSnapFacialCaptureResults) {
        print("MIBI Data:\n\(results.mibiDataString ?? "")")
    }
    
    func miSnapFacialCaptureDidFinishRecordingVideo(_ videoData: Data?) {
        // Check that videoData is not nil and handle it
    }
}
