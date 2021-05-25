//
//  MLCapture.swift
//  MachineLearningBasedSystem
//
//  Created by mabaoyan on 2021/5/24.
//

import Foundation
import AVKit

protocol CaptureImageDelegate: AnyObject {
    func captureOutput(_ output : CVPixelBuffer)
}


class MLCaputure : NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    weak var delegate: CaptureImageDelegate?
    let caputureSession : AVCaptureSession
    
    override init() {
        caputureSession = AVCaptureSession()
        caputureSession.sessionPreset = AVCaptureSession.Preset.photo
        super.init()
    }
    
    deinit {
        caputureSession.stopRunning()
    }
    
    func setupCaptureSession() -> AVCaptureSession {
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            fatalError("获取设备异常")
        }
        
        guard let input = try? AVCaptureDeviceInput.init(device: captureDevice) else { fatalError("获取设备异常")}
        caputureSession.addInput(input)
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue.init(label: "videoQueue"))
        caputureSession.addOutput(dataOutput)
        
        caputureSession.startRunning()
        return caputureSession
    }
    
    func captureLayer() -> AVCaptureVideoPreviewLayer {
        return AVCaptureVideoPreviewLayer(session: self.setupCaptureSession())
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        guard let _ = pixelBuffer else {
            return
        }
        
        guard let _ = self.delegate else {
            return
        }
        
        self.delegate?.captureOutput(pixelBuffer!)
    }
}
