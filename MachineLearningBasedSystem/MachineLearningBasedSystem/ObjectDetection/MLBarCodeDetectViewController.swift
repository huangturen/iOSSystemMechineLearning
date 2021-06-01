//
//  MLBarCodeDetectViewController.swift
//  MachineLearningBasedSystem
//
//  Created by mabaoyan on 2021/5/31.
//

import UIKit
import Vision

class MLBarCodeDetectViewController: MLBasedSystemViewController, CaptureImageDelegate {
    let textField = UITextField.init()
    let boxLayer = CAShapeLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        capture.delegate = self
        textField.frame = CGRect(x: 5, y: view.bounds.height - 200, width: view.bounds.width - 10, height: 200)
        textField.textAlignment = .center
        textField.textColor = .black
        textField.layer.borderWidth = 2
        textField.layer.borderColor = UIColor.blue.cgColor
        
        view.addSubview(textField)
        boxLayer.frame = view.bounds
        boxLayer.fillColor = nil
        boxLayer.strokeColor = UIColor.orange.cgColor
        
        videoLayer?.addSublayer(boxLayer)
    }
    
    override func createRequest() -> VNRequest? {
        let request = VNDetectBarcodesRequest.init()
        return request
    }
    
    override func processResults(result: [VNObservation]?) {
        guard let rets : [ VNBarcodeObservation ] = result as? [ VNBarcodeObservation ]  else {
            self.boxLayer.isHidden = true
            self.textField.isHidden = true
            return
        }
        
        guard let barcode = rets.first else {
            self.boxLayer.isHidden = true
            self.textField.isHidden = true
            return
        }
        
        self.boxLayer.isHidden = false
        self.textField.isHidden = false

        let pathT = CGAffineTransform(scaleX: boxLayer.bounds.width, y: -boxLayer.bounds.height)
        let transform = CGAffineTransform(translationX: 0, y: boxLayer.bounds.height)
        let path = CGMutablePath()
        DispatchQueue.main.async {
            path.addRect(barcode.boundingBox, transform: pathT.concatenating(transform))
            self.boxLayer.path = path
            self.textField.text = barcode.payloadStringValue!
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
