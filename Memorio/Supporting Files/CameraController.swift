//
//  CameraController.swift
//  Memorio
//
//  Created by Michal Dobes on 17/08/2020.
//

import Foundation
import AVFoundation
import UIKit
import CoreGraphics

class CameraController: NSObject {
    var captureSession: AVCaptureSession?
    
    var currentCameraPosition: CameraPosition?
    
    var audioDevice: AVCaptureDevice?
    var audioDeviceInput: AVCaptureDeviceInput?
    
    var frontCamera: AVCaptureDevice?
    var frontCameraInput: AVCaptureDeviceInput?
    
    var photoOutput: AVCapturePhotoOutput?
    var videoOutput: AVCaptureMovieFileOutput?
    
    var rearCamera: AVCaptureDevice?
    var rearCameraInput: AVCaptureDeviceInput?
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var flashMode = AVCaptureDevice.FlashMode.auto
    var photoCaptureCompletionBlock: ((UIImage?, Error?) -> Void)?
    var videoCaptureCompletionBlock: ((URL?, Error?) -> Void)?
    
    var captureState: CameraController.CaptureState = .none
    var currentVideoName: String = ""
    var currentVideoURLs: [URL] = []
}

extension CameraController {
    enum CaptureState {
        case none, start, capturing, end
    }
    
    func prepare(completionHandler: @escaping (Error?) -> Void) {
        func createCaptureSession() {
            self.captureSession = AVCaptureSession()
            captureSession?.sessionPreset = AVCaptureSession.Preset.hd1280x720
        }
        
        func configureCaptureDevices() throws {
            
            let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified)
            
            let cameras = session.devices.compactMap { $0 }
            guard !cameras.isEmpty else { throw CameraControllerError.noCamerasAvailable }
            
            for camera in cameras {
                if camera.position == .front {
                    self.frontCamera = camera
                }
                
                if camera.position == .back {
                    self.rearCamera = camera
                    
                    try camera.lockForConfiguration()
                    camera.focusMode = .continuousAutoFocus
                    camera.unlockForConfiguration()
                }
            }
            
            audioDevice = AVCaptureDevice.default(.builtInMicrophone, for: .audio, position: .unspecified)
        }
        
        func configureDeviceInputs() throws {
            guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
            
            if let rearCamera = self.rearCamera {
                self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
                
                if captureSession.canAddInput(self.rearCameraInput!) {
                    captureSession.addInput(self.rearCameraInput!)
                }
                
                self.currentCameraPosition = .rear
            }
            
            else if let frontCamera = self.frontCamera {
                self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
                
                if captureSession.canAddInput(self.frontCameraInput!) {
                    captureSession.addInput(self.frontCameraInput!)
                } else {
                    throw CameraControllerError.inputsAreInvalid
                }
                
                self.currentCameraPosition = .front
            }
            
            if let audioDevice = self.audioDevice {
                self.audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice)
                
                if captureSession.canAddInput(self.audioDeviceInput!) {
                    captureSession.addInput(self.audioDeviceInput!)
                }
            }
                
            else { throw CameraControllerError.noCamerasAvailable }
        }
        
        func configurePhotoOutput() throws {
            guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
            
            self.photoOutput = AVCapturePhotoOutput()
            self.photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
            
            self.videoOutput = AVCaptureMovieFileOutput()
            
            if captureSession.canAddOutput(self.photoOutput!) {
                captureSession.addOutput(self.photoOutput!)
            }
            
            if captureSession.canAddOutput(self.videoOutput!) {
                captureSession.addOutput(self.videoOutput!)
            }
            
            captureSession.startRunning()
        }
        
        DispatchQueue(label: "prepare").async {
            do {
                createCaptureSession()
                try configureCaptureDevices()
                try configureDeviceInputs()
                try configurePhotoOutput()
            }
                
            catch {
                DispatchQueue.main.async {
                    completionHandler(error)
                }
                
                return
            }
            
            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
    }
    
    func displayPreview(on view: UIView) throws {
        guard let captureSession = self.captureSession, captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspect
        self.previewLayer?.connection?.videoOrientation = .portrait
        
        view.layer.insertSublayer(self.previewLayer!, at: 0)
        self.previewLayer?.frame = view.frame
    }
    
    func switchCameras() throws {
        guard let currentCameraPosition = currentCameraPosition, let captureSession = self.captureSession, captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }
        
        captureSession.beginConfiguration()
        
        
        
        func switchToFrontCamera() throws {
            
            guard let rearCameraInput = self.rearCameraInput, captureSession.inputs.contains(rearCameraInput),
                  let frontCamera = self.frontCamera else { throw CameraControllerError.invalidOperation }
            
            self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
            
            captureSession.removeInput(rearCameraInput)
            
            if captureSession.canAddInput(self.frontCameraInput!) {
                captureSession.addInput(self.frontCameraInput!)
                
                self.currentCameraPosition = .front
            } else {
                throw CameraControllerError.invalidOperation
            }
        }
        
        func switchToRearCamera() throws {
            
            guard let frontCameraInput = self.frontCameraInput, captureSession.inputs.contains(frontCameraInput),
                  let rearCamera = self.rearCamera else { throw CameraControllerError.invalidOperation }
            
            self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
            
            captureSession.removeInput(frontCameraInput)
            
            if captureSession.canAddInput(self.rearCameraInput!) {
                captureSession.addInput(self.rearCameraInput!)
                
                self.currentCameraPosition = .rear
            }
            
            else { throw CameraControllerError.invalidOperation }
        }
        
        if captureState == .capturing {
            if let url = videoOutput?.outputFileURL {
                currentVideoURLs.append(url)
            }
            videoOutput?.stopRecording()
        }
        
        switch currentCameraPosition {
        case .front:
            try switchToRearCamera()
            
        case .rear:
            try switchToFrontCamera()
        }
        
        captureSession.commitConfiguration()
        
        if captureState == .capturing {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let fileUrl = paths[0].appendingPathComponent(currentVideoName + String(currentVideoURLs.count) + ".mov")
            videoOutput?.startRecording(to: fileUrl, recordingDelegate: self)
        }
    }
    
    func rotationByDevice() -> AVCaptureVideoOrientation {
        let currentDevice = UIDevice.current
        currentDevice.beginGeneratingDeviceOrientationNotifications()
        let deviceOrientation = currentDevice.orientation
        currentDevice.endGeneratingDeviceOrientationNotifications()
        switch deviceOrientation {
        case .landscapeLeft:
            return .landscapeRight
        case .landscapeRight:
            return .landscapeLeft
        default:
            return .portrait
        }
    }
    
    func captureImage(completion: @escaping (UIImage?, Error?) -> Void) {
        
        if let outputConnection = photoOutput?.connection(with: .video) {
            outputConnection.videoOrientation = rotationByDevice()
        }
        
        let settings = AVCapturePhotoSettings()
        settings.flashMode = self.flashMode
        self.photoOutput?.capturePhoto(with: settings, delegate: self)
        self.photoCaptureCompletionBlock = completion
    }
    
    func startCapturingVideo(completion: @escaping (URL?, Error?) -> Void, fileName: String) {
        
        if let outputConnection = videoOutput?.connection(with: .video) {
            outputConnection.videoOrientation = rotationByDevice()
        }
        
        self.currentVideoName = fileName
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let fileUrl = paths[0].appendingPathComponent(currentVideoName + String(currentVideoURLs.count) + ".mov")
        
        self.videoCaptureCompletionBlock = completion
        
        try? FileManager.default.removeItem(at: fileUrl)
        
        videoOutput?.startRecording(to: fileUrl, recordingDelegate: self)
        
        captureState = .capturing
    }
    
    func stopCapturingVideo() {
        captureState = .end
        videoOutput?.stopRecording()
    }
}

extension CameraController {
    func zoom(_ desiredZoomFactor: CGFloat) {
        var currentDevice: AVCaptureDevice?
        
        if currentCameraPosition == .rear {
            currentDevice = rearCamera
        } else if currentCameraPosition == .front {
            currentDevice = frontCamera
        }
        
        guard let device = currentDevice else { return }
        
        let maxZoomFactor = device.activeFormat.videoMaxZoomFactor
        
        do {
            
            try device.lockForConfiguration()
            defer { device.unlockForConfiguration() }
            
            let zoomFactor = device.videoZoomFactor + desiredZoomFactor
            device.videoZoomFactor = max(1.0, min(zoomFactor, maxZoomFactor))
        } catch {
            print(#function, error)
        }
    }
    
    func zoom(_ zoomAmount: CGFloat, maxZoomAmount: CGFloat) {
        var currentDevice: AVCaptureDevice?
        
        if currentCameraPosition == .rear {
            currentDevice = rearCamera
        } else if currentCameraPosition == .front {
            currentDevice = frontCamera
        }
        
        guard let device = currentDevice else { return }
        
        let maxZoomFactor = device.activeFormat.videoMaxZoomFactor
        
        do {
            
            try device.lockForConfiguration()
            defer { device.unlockForConfiguration() }
            
            let desiredZoomAmount = ((maxZoomAmount-zoomAmount)/maxZoomAmount) * maxZoomFactor
            device.videoZoomFactor = max(1.0, min(desiredZoomAmount, maxZoomFactor))
        } catch {
            print(#function, error)
        }
    }
}

extension CameraController: AVCapturePhotoCaptureDelegate {
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            self.photoCaptureCompletionBlock?(nil, error)
        } else if let imageData = photo.fileDataRepresentation(), let img = UIImage(data: imageData) {
            self.photoCaptureCompletionBlock?(img, nil)
        }
    }
}

extension CameraController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if captureState == .end {
            currentVideoURLs.append(outputFileURL)
            var assets = [AVAsset]()
            DispatchQueue(label: "mdobes.memorio.imageprocessing").async {
                for currentVideoURL in self.currentVideoURLs {
                    assets.append(AVAsset(url: currentVideoURL))
                }
                
                self.merge(arrayVideos: assets, fileName: self.currentVideoName) { (url, error) in
                    self.videoCaptureCompletionBlock?(url, error)
                    for currentVideoURL in self.currentVideoURLs {
                        try? FileManager.default.removeItem(at: currentVideoURL)
                    }
                }
            }
            
        } else if captureState == .none {
            currentVideoURLs.append(outputFileURL)
            DispatchQueue(label: "mdobes.memorio.imageprocessing").async {
                for currentVideoURL in self.currentVideoURLs {
                    try? FileManager.default.removeItem(at: currentVideoURL)
                }
            }
        }
    }
    
    
    func merge(arrayVideos: [AVAsset], fileName: String, completion: @escaping (URL?, Error?) -> ()) {
        let mainComposition = AVMutableComposition()
        let compositionVideoTrack = mainComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        compositionVideoTrack?.preferredTransform = CGAffineTransform(rotationAngle: .pi / 2)
        
        let soundtrackTrack = mainComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        var insertTime = CMTime.zero
        
        for videoAsset in arrayVideos {
            try! compositionVideoTrack?.insertTimeRange(CMTimeRangeMake(start: .zero, duration: videoAsset.duration), of: videoAsset.tracks(withMediaType: .video)[0], at: insertTime)
            try! soundtrackTrack?.insertTimeRange(CMTimeRangeMake(start: .zero, duration: videoAsset.duration), of: videoAsset.tracks(withMediaType: .audio)[0], at: insertTime)
            
            insertTime = CMTimeAdd(insertTime, videoAsset.duration)
        }
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let outputFileURL = paths[0].appendingPathComponent(fileName + "_").appendingPathExtension("mov")

        try? FileManager.default.removeItem(at: outputFileURL)
        
        var exportQuality = AVAssetExportPreset1280x720
        
        if UserDefaults.standard.value(forKey: Constants.videoExportSettings) != nil {
            exportQuality = UserDefaults.standard.value(forKey: Constants.videoExportSettings) as! String
        }

        let exporter = AVAssetExportSession(asset: mainComposition, presetName: exportQuality)

        exporter?.outputURL = outputFileURL
        exporter?.outputFileType = .mov
        exporter?.shouldOptimizeForNetworkUse = false

        exporter?.exportAsynchronously {
            switch exporter?.status {
            case .completed:
                if let url = exporter?.outputURL {
                    completion(url, nil)
                }
                if let error = exporter?.error {
                    completion(nil, error)
                }
            default:
                completion(nil, nil)
                break
            }
        }
        
    }
}

class VideoCompositor {
    public func addViewTo(videoURL: URL, watermark: UIImage, removeOriginal: Bool = true, saveToDirectory: FileManager.SearchPathDirectory = .documentDirectory, networkUse: Bool = false, completion: @escaping (URL?, Error?) -> ()) {
        
        let asset = AVAsset(url: videoURL)
        let composition = AVMutableComposition()

        guard let compositionTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) else { completion(nil, nil)
            return
        }
        
        let assetTrack = asset.tracks(withMediaType: .video)[0]
        
        do {
            let timeRange = CMTimeRange(start: .zero, duration: asset.duration)
            try compositionTrack.insertTimeRange(timeRange, of: assetTrack, at: .zero)
            
            if let audioAssetTrack = asset.tracks(withMediaType: .audio).first,
               let compositionAudioTrack = composition.addMutableTrack(
                withMediaType: .audio,
                preferredTrackID: kCMPersistentTrackID_Invalid) {
                try compositionAudioTrack.insertTimeRange(
                    timeRange,
                    of: audioAssetTrack,
                    at: .zero)
            }
        } catch {
            print(#function, error)
            completion(nil, error)
            return
        }
        
        compositionTrack.preferredTransform = assetTrack.preferredTransform
        
        let paths = FileManager.default.urls(for: saveToDirectory, in: .userDomainMask)
        let inputFileName = videoURL.deletingPathExtension().lastPathComponent
        let outputFileURL = paths[0].appendingPathComponent(inputFileName + "__").appendingPathExtension("mov")
        
        try? FileManager.default.removeItem(at: outputFileURL)
        
        let watermarkFilter = CIFilter(name: "CISourceOverCompositing")!
        let watermarkImage = CIImage(image: watermark)!
        let videoComposition = AVVideoComposition(asset: asset) { (filteringRequest) in
            let source = filteringRequest.sourceImage
            watermarkFilter.setValue(source, forKey: kCIInputBackgroundImageKey)
            let widthScale = source.extent.width/watermarkImage.extent.width
            let heightScale = source.extent.height/watermarkImage.extent.height
            watermarkFilter.setValue(watermarkImage.transformed(by: .init(scaleX: widthScale, y: heightScale)), forKey: kCIInputImageKey)
            filteringRequest.finish(with: watermarkFilter.outputImage!, context: nil)
        }
        
        var exportQuality = AVAssetExportPreset1280x720
        
        if UserDefaults.standard.value(forKey: Constants.videoExportSettings) != nil {
            exportQuality = UserDefaults.standard.value(forKey: Constants.videoExportSettings) as! String
        }
        
        guard let export = AVAssetExportSession(asset: asset, presetName: exportQuality) else {
            completion(nil, nil)
            return
        }
        
        export.videoComposition = videoComposition
        export.outputURL = outputFileURL
        export.outputFileType = .mov
        export.shouldOptimizeForNetworkUse = networkUse
        
        export.exportAsynchronously {
            switch export.status {
            case .completed:
                DispatchQueue.main.async {
                    if let url = export.outputURL {
                        completion(url, nil)
                    }
                    if let error = export.error {
                        completion(nil, error)
                    }
                    if removeOriginal {
                        try? FileManager.default.removeItem(at: videoURL)
                    }
                }
            default:
                if let error = export.error {
                    print(#function, error)
                    completion(nil, error)
                    if removeOriginal {
                        try? FileManager.default.removeItem(at: videoURL)
                    }
                }
                break
            }
        }
    }
}


extension CameraController {
    enum CameraControllerError: Swift.Error {
        case captureSessionAlreadyRunning
        case captureSessionIsMissing
        case inputsAreInvalid
        case invalidOperation
        case noCamerasAvailable
        case unknown
    }
    
    public enum CameraPosition {
        case front
        case rear
    }
}

