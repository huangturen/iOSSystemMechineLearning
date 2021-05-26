//
//  ImageClassifyViewController.swift
//  MachineLearningBasedSystem
//
//  Created by mabaoyan on 2021/5/25.
//

import UIKit
import Vision

class MLImageClassifyViewController : MLBasedSystemViewController, CaptureImageDelegate{
    let type : MLSystemType = .classify
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
        label.textColor = .black
        view.addSubview(label)
    }
    
    
    @available(iOS 11.0, *)
    override func createRequest() -> VNRequest? {
        var request: VNRequest? = nil
        if #available(iOS 13.0, *) {
            request = VNClassifyImageRequest()
        }
        return request
    }
    
    @available(iOS 11.0, *)
    override func processResults(result: [VNObservation]?) -> Void {
        guard let ret : VNClassificationObservation = result?.first as? VNClassificationObservation else { return }
        label.text = ret.identifier
    }
}
