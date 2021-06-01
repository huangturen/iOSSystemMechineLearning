//
//  MLTextRecongnizeViewController.swift
//  MachineLearningBasedSystem
//
//  Created by mabaoyan on 2021/5/31.
//

import UIKit
import Vision

@available(iOS 13.0, *)
class MLTextRecongnizeViewController: MLBasedSystemViewController, CaptureImageDelegate {
    var date:NSDate?
    override func viewDidLoad() {
        super.viewDidLoad()
        capture.delegate = self
        
    }
    
    override func createRequest() -> VNRequest? {
        date = NSDate()
        let request = VNRecognizeTextRequest.init()
//        if #available(iOS 14.0, *) {
//            let arr = try? VNRecognizeTextRequest.supportedRecognitionLanguages(for: .accurate, revision: VNRecognizeTextRequestRevision2)
//            print(arr as Any)
//        } else {
//            // Fallback on earlier versions
//        }
        request.usesLanguageCorrection = true
        request.recognitionLevel = .accurate
        return request
    }
    
    override func processResults(result: [VNObservation]?) {
        guard let rets : [ VNRecognizedTextObservation ] = result as? [ VNRecognizedTextObservation ] else {
            return
        }
        
        guard let texts = rets.first?.topCandidates(2) else {
            return
        }
        
        for object in texts {
            print( object.string, object.confidence )
        }
    }
}
