//
//  ViewController.swift
//  InterviewTasksClip
//
//  Created by Thejas K on 16/07/24.
//

import UIKit
import AVFoundation
import ARKit
import SceneKit
import ReplayKit

class ViewController: UIViewController {
    
    @IBOutlet weak var appClipLabel: UILabel!
    
    @IBOutlet weak var invocationLabel: UILabel!
    
    @IBOutlet weak var resetCountLabel: UILabel!
    
    var sceneView: ARSCNView!
    var captureSession: AVCaptureSession!
    var videoOutput: AVCaptureVideoDataOutput!
    var assetWriter: AVAssetWriter!
    var assetWriterInput: AVAssetWriterInput!
    var videoInput: AVAssetWriterInput!
    var pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor!
    var isRecording = false
    
    var outputURL: URL!
    var scnRenderer: SCNRenderer!
    
    var renderView: UIView!
    
    var renderTarget: MTLTexture!
    var commandQueue: MTLCommandQueue!
    var device: MTLDevice!
    
    static var resetCount = 0
    
    var recorder : Recorder = Recorder()
    
    @IBOutlet weak var recorderView: UIView!
    
    var resetText : String {
        return "Reset count = \(ViewController.resetCount)"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        DispatchQueue.main.async {
            self.appClipLabel.text = "Invocation Url"
            self.resetCountLabel.text = self.resetText
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Start", style: .plain, target: self, action: #selector(startRecordingWithRPKit))
        
        recorder.view = self.view
        
        self.view.sendSubviewToBack(recorderView)
        self.recorderView.isHidden = true
        
        setupRenderView()
        setupARSceneView()
        setupCaptureSession()
        //setupRecording()
    }
    
    func setUpAssetWriter() {
        
        let outputPath = FileManager.default.urls(for: .userDirectory, in: .userDomainMask).first?.appendingPathComponent("output.mp4", conformingTo: .movie)
        
        let outputURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("output.mp4")
        do {
            assetWriter = try AVAssetWriter(outputURL: outputPath ?? outputURL, fileType: .mp4)
        } catch {
            print("Error initializing AVAssetWriter: \(error.localizedDescription)")
        }
    }
    
    func configureVideoInput() {
        
        guard let assetWriter = assetWriter else { return }

        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: 1920,
            AVVideoHeightKey: 1080
        ]
        
        videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        videoInput?.expectsMediaDataInRealTime = true

        if assetWriter.canAdd(videoInput!) {
            assetWriter.add(videoInput!)
        } else {
            print("Cannot add video input to asset writer")
        }
    }
    
    func appendSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        guard let videoInput = videoInput, videoInput.isReadyForMoreMediaData else { return }
        
        if let error = assetWriter?.error {
            print("Failed to append sample buffer: \(error.localizedDescription)")
            
            print("AVAssetWriter status: \(assetWriter?.status)")
        } else {
            print("Failed to append sample buffer: unknown error")
        }
    }
    
    @objc func startRecordingWithRPKit() {
        
//        let recorder = RPScreenRecorder.shared()
//        
//        recorder.startCapture(handler: { (sampleBuffer, bufferType, error) in
//            guard error == nil else {
//                print("Error capturing screen: \(error!.localizedDescription)")
//                return
//            }
//            
//            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Stop", style: .plain, target: self, action: #selector(self.stopRecordingWithRPKit))
//            
//            if bufferType == .video {
//                self.handleCapturedBuffer(sampleBuffer: sampleBuffer)
//            }
//            
//        }) { (error) in
//            if let error = error {
//                print("Error starting capture: \(error.localizedDescription)")
//            } else {
//                print("Started capturing successfully")
//            }
//        }
        
        setUpAssetWriter()
        configureVideoInput()
        
        guard let assetWriter = assetWriter else { return }
        assetWriter.startWriting()
        assetWriter.startSession(atSourceTime: CMTime.zero)
        
        //guard let assetWriter = assetWriter, let videoInput = videoInput else { return }
        
//        videoInput.markAsFinished()
//        assetWriter.finishWriting {
//            print("Finished writing video")
//        }
        
        DispatchQueue.main.async {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Stop", style: .plain, target: self, action: #selector(self.stopRecordingWithRPKit))
        }
        
        RPScreenRecorder.shared().startCapture(handler: { (sampleBuffer, bufferType, error) in
            if let error = error {
                print("Error during capture: \(error.localizedDescription)")
                return
            }
            
            if bufferType == .video {
                self.appendSampleBuffer(sampleBuffer)
            }
        }) { error in
            if let error = error {
                print("Error starting capture: \(error.localizedDescription)")
            } else {
                print("Started capturing successfully")
            }
        }
        
//        recorder.startRecording{ [unowned self] (error) in
//            if let unwrappedError = error {
//                print(unwrappedError.localizedDescription)
//            } else {
//                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Stop", style: .plain, target: self, action: #selector(self.stopRecordingWithRPKit))
//            }
//        }
        
    }
    
    @objc func stopRecordingWithRPKit() {
        
//        let recorder = RPScreenRecorder.shared()
//        
//        recorder.stopRecording { [unowned self] (preview, error) in
//            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Start", style: .plain, target: self, action: #selector(self.startRecordingWithRPKit))
//            
//            if let unwrappedPreview = preview {
//                unwrappedPreview.previewControllerDelegate = self
//                self.present(unwrappedPreview, animated: true)
//            }
//        }
        
        guard let assetWriter = assetWriter, let videoInput = videoInput else { return }
        
        videoInput.markAsFinished()
        assetWriter.finishWriting {
            print("Finished writing video")
        }
        
        DispatchQueue.main.async {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Start", style: .plain, target: self, action: #selector(self.startRecordingWithRPKit))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(resetInvocationUrl), name: AppDelegate.ClearInvocationUrlNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshViewAfterTokenReset), name: AppDelegate.RefreshViewAfterResetNotification, object: nil)
    }
    
    @objc func resetInvocationUrl() {
        DispatchQueue.main.async {
            self.invocationLabel.text = ""
            ViewController.resetCount += 1
        }
    }
    
    @objc func refreshViewAfterTokenReset() {
        
        DispatchQueue.main.async {
            
            if let url = AppUserDefaults.getInvocationUrl() {
                self.invocationLabel.text = url
                self.resetCountLabel.text = self.resetText
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        var url = "Sample Url"
        
        if let value = AppUserDefaults.getInvocationUrl() {
            url = value
        }
        
        DispatchQueue.main.async {
            self.invocationLabel.text = url
        }
    }

    func setupRenderView() {
        renderView = UIView(frame: view.frame)
        renderView.isHidden = true
        view.addSubview(renderView)
        
        device = MTLCreateSystemDefaultDevice()
        commandQueue = device.makeCommandQueue()
        
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .bgra8Unorm,
            width: Int(view.frame.width),
            height: Int(view.frame.height),
            mipmapped: false
        )
        
        textureDescriptor.usage = [.shaderRead, .renderTarget]
        renderTarget = device.makeTexture(descriptor: textureDescriptor)
    }
    
    func setupARSceneView() {
        sceneView = ARSCNView(frame: view.frame)
        view.addSubview(sceneView)
        
        scnRenderer = SCNRenderer(device: device, options: nil)
        scnRenderer.scene = sceneView.scene
        scnRenderer.pointOfView = sceneView.pointOfView
        
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    func setupCaptureSession() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        
        guard let camera = AVCaptureDevice.default(for: .video) else {
            print("No camera available")
            return
        }
        
        do {
            let cameraInput = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(cameraInput) {
                captureSession.addInput(cameraInput)
            }
        } catch {
            print("Error setting up camera input: \(error)")
            return
        }
        
        videoOutput = AVCaptureVideoDataOutput()
        videoOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        let queue = DispatchQueue(label: "videoQueue")
        videoOutput.setSampleBufferDelegate(self, queue: queue)
        
        captureSession.startRunning()
    }
    
    func setupRecording() {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        outputURL = paths[0].appendingPathComponent("output.mov")
        
        do {
            assetWriter = try AVAssetWriter(outputURL: outputURL, fileType: .mov)
        } catch {
            print("Error setting up asset writer: \(error)")
            return
        }
        
        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: NSNumber(value: Float(view.frame.width)),
            AVVideoHeightKey: NSNumber(value: Float(view.frame.height))
        ]
        
        assetWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        assetWriterInput.expectsMediaDataInRealTime = true
        
        if assetWriter.canAdd(assetWriterInput) {
            assetWriter.add(assetWriterInput)
        }
        
        pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: assetWriterInput,
            sourcePixelBufferAttributes: nil
        )
    }

    func startRecording() {
        guard !isRecording else { return }
        
        isRecording = true
        assetWriter.startWriting()
        assetWriter.startSession(atSourceTime: CMTime.zero)
    }
    
    func stopRecording() {
        guard isRecording else { return }
        
        isRecording = false
        assetWriterInput.markAsFinished()
        assetWriter.finishWriting {
            print("Video recorded successfully to \(self.outputURL!)")
        }
    }
    
}

extension ViewController : AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard isRecording else { return }

        if assetWriterInput.isReadyForMoreMediaData {
            let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
            let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
            pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: timestamp)

            renderARContent(at: timestamp)
        }
    }

    func renderARContent(at timestamp: CMTime) {
        let commandBuffer = commandQueue.makeCommandBuffer()!
        
        scnRenderer.render(atTime: CFTimeInterval(CMTimeGetSeconds(timestamp)), viewport: renderView.bounds, commandBuffer: commandBuffer, passDescriptor: MTLRenderPassDescriptor())

        commandBuffer.commit()
    }
    
}

extension ViewController : RPPreviewViewControllerDelegate {
    
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        dismiss(animated: true)
    }
    
    func handleCapturedBuffer(sampleBuffer: CMSampleBuffer) {
            guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                return
            }

            // Convert imageBuffer to UIImage
            let ciImage = CIImage(cvImageBuffer: imageBuffer)
            let context = CIContext(options: nil)
            guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
                return
            }
            let image = UIImage(cgImage: cgImage)

            // Crop the UIImage to the frame of the recordView
            let croppedImage = cropImageToView(image: image, view: recorderView)

            // Process the cropped image, e.g., save to file or stream it
            // Note: This is just an example, processing the image as required
        }
    
    func cropImageToView(image: UIImage, view: UIView) -> UIImage? {
        
            guard let superview = view.superview else {
                return nil
            }

            // Get the frame of the view relative to the superview
            let viewFrame = view.convert(view.bounds, to: superview)
            
            // Crop the image
            let scale = UIScreen.main.scale
            let scaledFrame = CGRect(x: viewFrame.origin.x * scale,
                                     y: viewFrame.origin.y * scale,
                                     width: viewFrame.size.width * scale,
                                     height: viewFrame.size.height * scale)

            guard let cgImage = image.cgImage?.cropping(to: scaledFrame) else {
                return nil
            }

            return UIImage(cgImage: cgImage)
        }
}
