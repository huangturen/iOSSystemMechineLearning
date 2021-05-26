//
//  SystemMLBaseViewController.swift
//  MachineLearningBasedSystem
//
//  Created by mabaoyan on 2021/5/25.
//

import UIKit
import Vision
import AVKit

class MLBasedSystemViewController: UIViewController {
    deinit {
        capture.caputureSession.stopRunning()
    }
 
    let capture = MLCaputure()
    var videoLayer : AVCaptureVideoPreviewLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        videoLayer = capture.captureLayer()
        videoLayer!.frame = view.layer.bounds;
        videoLayer!.videoGravity = .resizeAspectFill
        view.layer.addSublayer(videoLayer!)
    }
    
    @available(iOS 11.0, *)
    func captureOutput(_ output: CVPixelBuffer) {
        let handler = VNImageRequestHandler.init(cvPixelBuffer: output, orientation: .right , options: [:] )
        let result = processSystemRequestOnHandler(on: handler)
        DispatchQueue.main.async {
            self.processResults(result: result)
        }
    }
    
    override func viewDidLayoutSubviews() {
        updateLayersGeometry()
        super.viewDidLayoutSubviews()
    }
    
    @available(iOS 11.0, *)
    func processSystemRequestOnHandler(on handler: VNImageRequestHandler?) -> [VNObservation]? {
        guard let request:VNRequest = createRequest() else {
            return nil
        }
        
        guard let _ = handler else {
            return nil
        }
        
        do {
            try? handler!.perform([request])
        } catch  {
            print("error")
        }
        
        return request.results as? [VNObservation];
    }
    
    @available(iOS 11.0, *)
    func processResults(result: [VNObservation]?) -> Void {
        fatalError("SubClass should impl")
    }
    
    @available(iOS 11.0, *)
    func createRequest() -> VNRequest?{
        fatalError("SubClass should impl")
    }
    
    func updateLayersGeometry() -> Void {
    }
}
