//
//  ObjectDetectionViewController.swift
//  MachineLearningBasedSystem
//
//  Created by mabaoyan on 2021/5/25.
//

import UIKit
import Vision

class ImageClassifyViewController : SystemMLBaseViewController, CaptureImageDelegate{
    let type : SystemMLType = .classify
    let label = UILabel.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        capture.delegate = self
       
        view.backgroundColor = .white
        label.frame = CGRect(x:0,
                             y:view.frame.height - 100,
                             width:view.frame.width,
                             height: 20)
        label.textAlignment = .center
        view.addSubview(label)
    }

    
    
    @available(iOS 11.0, *)
    func captureOutput(_ output: CVPixelBuffer) {
        let handler = VNImageRequestHandler.init(cvPixelBuffer: output, options: [:])
        let result = processSystemRequestOnHandler(type, on: handler)
        DispatchQueue.main.async {
            self.processResult(with: self.type, result: result)
        }
    }
    
    @available(iOS 11.0, *)
    func processSystemRequestOnHandler(_ type : SystemMLType, on handler: VNImageRequestHandler?) -> VNObservation? {
        guard let request:VNRequest = createRequest(with: type) else {
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
        
        return request.results?.first as? VNObservation;
    }
    
    
    @available(iOS 11.0, *)
    func createRequest(with type : SystemMLType) -> VNRequest? {
        var request: VNRequest? = nil
        switch type {
        case .classify:
            if #available(iOS 13.0, *) {
                request = VNClassifyImageRequest()
            }
            break
        case .objectDectect:
            request = VNDetectRectanglesRequest()
            break
        case .faceDectect:
            request = VNDetectFaceLandmarksRequest()
            break
        default:
            break
        }
        return request
    }
    
    func processResult(with type: SystemMLType, result: VNObservation?) -> Void {
        switch type {
        case .classify:
            guard let ret : VNClassificationObservation = result as? VNClassificationObservation else { return }
            label.text = ret.identifier
            break
        case .objectDectect:
            guard let ret : VNDetectedObjectObservation = result as? VNDetectedObjectObservation  else {
                return
            }
            print(ret.boundingBox, ret.confidence)
            break
        case .faceDectect:
            break
            
        default:
            break
        }
    }
}
