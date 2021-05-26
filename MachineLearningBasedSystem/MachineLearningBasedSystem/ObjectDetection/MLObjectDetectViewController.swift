//
//  ObjectDetectViewController.swift
//  MachineLearningBasedSystem
//
//  Created by mabaoyan on 2021/5/25.
//

import UIKit
import Vision

class MLObjectDetectViewController : MLBasedSystemViewController, CaptureImageDelegate{
    let type : MLSystemType = .objectDectect
    let boxLayer : CAShapeLayer = CAShapeLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        capture.delegate = self
       
        view.backgroundColor = .white
//        boxLayer.frame = CGRect(x:0,
//                             y:view.frame.height - 100,
//                             width:view.frame.width,
//                             height: 20)
//        label.textAlignment = .center
        boxLayer.frame = view.layer.bounds
        videoLayer!.addSublayer(boxLayer)
        boxLayer.strokeColor = UIColor.yellow.cgColor
        boxLayer.fillColor = nil
    }
    
    @available(iOS 11.0, *)
    override func createRequest() -> VNRequest? {
        var request: VNRequest? = nil
        if #available(iOS 13.0, *) {
            request = VNDetectRectanglesRequest()
        }
        return request
    }
    
    @available(iOS 11.0, *)
    override func processResults(result: [VNObservation]?) -> Void {
        guard let rets : [VNDetectedObjectObservation] = result as? [ VNDetectedObjectObservation ] else { return }
        let pathT = CGAffineTransform(scaleX: boxLayer.bounds.width, y: boxLayer.bounds.height)
        let path = CGMutablePath()
        for object in rets {
            path.addRect(object.boundingBox, transform: pathT)
        }
        boxLayer.path = path
    }
    
    override func updateLayersGeometry() {
        if let baseLayer = videoLayer {
            let outputRect = CGRect(x: 0, y: 0, width: 1, height: 1)
            let videoRect = baseLayer.layerRectConverted(fromMetadataOutputRect: outputRect)
            boxLayer.frame = videoRect
        }
    }
}
