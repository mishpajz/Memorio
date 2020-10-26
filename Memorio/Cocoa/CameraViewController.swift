//
//  CameraViewController.swift
//  Memorio
//
//  Created by Michal Dobes on 17/08/2020.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {

    @IBOutlet weak var capturePreviewView: UIView!
    
    @IBOutlet weak var toggleFlashButton: UIButton!
    @IBOutlet weak var flipCameraButton: UIButton!
    
    @IBOutlet weak var captureButtonBackgroud: UIVisualEffectView!
    @IBOutlet weak var captureButton: UIView!
    @IBOutlet weak var captureButtonSpinner: UIActivityIndicatorView!
    
    weak var delegate: CameraViewControllerDelegate?
    
    let cameraController = CameraController()
    
    var focusIndicator: UIView!
    
    private var processing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        captureButtonSpinner.isHidden = true
        
        func configureCameraController() {
            cameraController.prepare { (error) in
                if let error = error {
                    print(#function, error)
                }
                
                try? self.cameraController.displayPreview(on: self.capturePreviewView)
                
                self.flashAvailability()
            }
        }
        
        func styleButtons() {
            toggleFlashButton.tintColor = .white
            flipCameraButton.tintColor = .white
            
            captureButtonBackgroud.layer.cornerRadius = captureButtonBackgroud.frame.height/2
            captureButton.layer.cornerRadius = captureButton.frame.height/2
        }
        
        func setGestures() {
            let pinchZoomGesture = UIPinchGestureRecognizer(target: self, action: #selector(handleZoomPinch(_:)))
            capturePreviewView.addGestureRecognizer(pinchZoomGesture)
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            self.captureButton.addGestureRecognizer(tapGesture)
            
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
            longPress.minimumPressDuration = 0.3
            self.captureButton.addGestureRecognizer(longPress)
            
            let tapFocusGesture = UITapGestureRecognizer(target: self, action: #selector(tapToFocus(_:)))
            self.capturePreviewView.addGestureRecognizer(tapFocusGesture)
        }
        
        func setFocusIndicator() {
            focusIndicator = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            view.addSubview(focusIndicator)
            focusIndicator.layer.borderWidth = 5
            focusIndicator.layer.borderColor = UIColor.white.cgColor
            focusIndicator.backgroundColor = UIColor.clear
            focusIndicator.layer.cornerRadius = 10
            focusIndicator.clipsToBounds = true
            focusIndicator.isHidden = true
        }
        
        
        styleButtons()
        configureCameraController()
        setGestures()
        setFocusIndicator()
    }
    
    func flashAvailability() {
        if cameraController.doesCameraSupportFlash() {
            toggleFlashButton.isHidden = false
        } else {
            toggleFlashButton.isHidden = true
            setFlashButtonStyle()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cancel()
    }
    
    @IBAction func flipCamera(_ sender: Any) {
        do {
            try cameraController.switchCameras()
        } catch {
            print(#function, error)
        }
        
        flashAvailability()
    }
    
    @IBAction func toggleFlash(_ sender: Any) {
        if cameraController.flashMode == .on {
            cameraController.flashMode = .off
        } else if cameraController.flashMode == .auto {
            cameraController.flashMode = .on
        } else {
            cameraController.flashMode = .auto
        }
        
        setFlashButtonStyle()
    }
    
    private func setFlashButtonStyle() {
        if cameraController.flashMode == .on {
            toggleFlashButton.tintColor = .white
            toggleFlashButton.setImage(UIImage(systemName: "bolt.fill"), for: .normal)
        } else if cameraController.flashMode == .auto {
            toggleFlashButton.tintColor = .white
            toggleFlashButton.setImage(UIImage(systemName: "bolt.badge.a.fill"), for: .normal)
        } else {
            toggleFlashButton.tintColor = .white
            toggleFlashButton.setImage(UIImage(systemName: "bolt.slash.fill"), for: .normal)
        }
    }
    
    @objc func handleZoomPinch(_ sender: UIPinchGestureRecognizer) {
        if sender.state == .changed {
            let pinchVelocityDividerFactor: CGFloat = 5.0
            
            let desiredZoomFactor = (sender.velocity / pinchVelocityDividerFactor)
            cameraController.zoom(desiredZoomFactor)
        }
    }
    
    @objc func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            if !processing {
                startRecording()
                captureButton.backgroundColor = UIColor(named: "mainColor")
                processing = true
            }
        }
        if sender.state == .changed || sender.state == .began {
            let location = sender.location(in: self.view)
            sender.view!.center = CGPoint(x: location.x, y: location.y)
            
            let zoomAmount = sender.view!.center.y
            let maxZoomAmount = capturePreviewView.frame.height - 90
            cameraController.zoom(zoomAmount, maxZoomAmount: maxZoomAmount)
        }
        if sender.state == .ended {
            captureButtonSpinner.isHidden = false
            captureButtonSpinner.startAnimating()
            captureButton.addSubview(UIActivityIndicatorView())
            cameraController.stopCapturingVideo()
        }
    }
    
    func startRecording() {
        if cameraController.captureState != .capturing, cameraController.captureState != .start, !processing {
            let fileName = UUID().uuidString
            cameraController.startCapturingVideo(completion: { [weak self] (url, error) in
                DispatchQueue.main.async { [weak self] in
                    if let url = url {
                        self?.delegate?.didCaptureVideo(url)
                        self?.cameraController.captureSession?.stopRunning()
                    }
                }
            }, fileName: fileName)
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        if !processing {
            processing = true
            captureButton.backgroundColor = UIColor(named: "mainColor")
            captureButtonSpinner.isHidden = false
            captureButtonSpinner.startAnimating()
            cameraController.captureImage { [weak self] (image, error) in
                DispatchQueue.main.async { [weak self] in
                    if let image = image {
                        self?.delegate?.didCapturePhoto(image)
                        self?.cameraController.captureSession?.stopRunning()
                    }
                }
            }
        }
    }
    
    @IBAction func cancel() {
        if !processing {
            if cameraController.captureState == .capturing {
                cameraController.captureState = .none
                cameraController.videoOutput?.stopRecording()
            }
            for currentVideoURL in cameraController.currentVideoURLs {
                try? FileManager.default.removeItem(at: currentVideoURL)
            }
            cameraController.captureSession?.stopRunning()
            delegate?.didCancel()
        }
    }
    
    @objc func tapToFocus(_ sender: UITapGestureRecognizer) {
        let screenSize = capturePreviewView.bounds.size
        let x = sender.location(in: capturePreviewView).y / screenSize.height
        let y = 1 - sender.location(in: capturePreviewView).x / screenSize.width
        let focusPoint = CGPoint(x: x, y: y)
        var device = cameraController.rearCamera
        if cameraController.currentCameraPosition == .front {
            device = cameraController.frontCamera
        }
        
        let location = sender.location(in: self.view)
        focusIndicator.center = CGPoint(x: location.x, y: location.y)
        focusIndicator.isHidden = false
        focusIndicator.alpha = 1
        
        do {
            try device?.lockForConfiguration()
            if device?.isFocusPointOfInterestSupported == true {
                device?.focusPointOfInterest = focusPoint
                device?.focusMode = .autoFocus
            }
            if device?.isExposurePointOfInterestSupported == true {
                device?.exposurePointOfInterest = focusPoint
                device?.exposureMode = AVCaptureDevice.ExposureMode.autoExpose
            }
        }
        catch {
            print(#function, error)
        }
    
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.focusIndicator.alpha = 0
        } completion: { [weak self] _ in
            self?.focusIndicator.isHidden = true
        }

    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

protocol CameraViewControllerDelegate: AnyObject {
    func didCapturePhoto(_ photo: UIImage)
    
    func didCaptureVideo(_ url: URL)
    
    func didCancel()
}
