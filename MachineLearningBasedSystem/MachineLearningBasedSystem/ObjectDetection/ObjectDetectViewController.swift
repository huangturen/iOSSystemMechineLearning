//
//  ObjectDetectViewController.swift
//  MachineLearningBasedSystem
//
//  Created by mabaoyan on 2021/5/25.
//

import UIKit
import Vision

class ObjectDetectViewController : SystemMLBaseViewController, CaptureImageDelegate{
    let type : SystemMLType = .objectDectect
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
        boxLayer.frame = view.frame
        view.layer.addSublayer(boxLayer)
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
        guard let rets : [VNDetectedObjectObservation] = result as? [VNDetectedObjectObservation] else { return }
        let pathT = CGAffineTransform(scaleX: boxLayer.bounds.width, y: boxLayer.bounds.height)
        let path = CGMutablePath()
        for object in rets {
            path.addRect(object.boundingBox, transform: pathT)
        }
        boxLayer.path = path
    }
}
