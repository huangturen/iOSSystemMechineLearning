//
//  MLTextDetectViewController.swift
//  MachineLearningBasedSystem
//
//  Created by mabaoyan on 2021/5/31.
//

import UIKit
import Vision

class MLTextDetectViewController: MLBasedSystemViewController, CaptureImageDelegate {
    let boxLayer : CAShapeLayer = CAShapeLayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        capture.delegate =  self
        boxLayer.frame = view.layer.bounds
        videoLayer!.addSublayer(boxLayer)
        boxLayer.strokeColor = UIColor.yellow.cgColor
        boxLayer.fillColor = nil
    }
    
    override func createRequest() -> VNRequest? {
        let request = VNDetectTextRectanglesRequest.init()
        request.reportCharacterBoxes = true
        return request
    }
    
    override func processResults(result: [VNObservation]?) {
        guard let rets : [VNTextObservation] = result as? [VNTextObservation] else {
            return
        }
        
        let pathT = CGAffineTransform(scaleX: boxLayer.bounds.width, y: -boxLayer.bounds.height)
        let transform = CGAffineTransform(translationX: 0, y: boxLayer.bounds.height)
        let path = CGMutablePath()
        DispatchQueue.main.async {
            for wordObsevation in rets {
                path.addRect(wordObsevation.boundingBox, transform: pathT.concatenating(transform))
                self.boxLayer.path = path
            }
        }
        
    }
    
    override func updateLayersGeometry() {
        if let baseLayer = videoLayer {
            let outputRect = CGRect(x: 0, y: 0, width: 1, height: 1)
            let videoRect = baseLayer.layerRectConverted(fromMetadataOutputRect: outputRect)
            boxLayer.frame = videoRect
        }
    }
}
