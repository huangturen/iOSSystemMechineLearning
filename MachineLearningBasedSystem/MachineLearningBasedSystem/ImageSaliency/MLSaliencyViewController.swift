//
//  MLSaliencyViewController.swift
//  MachineLearningBasedSystem
//
//  Created by mabaoyan on 2021/5/26.
//

import UIKit
import Vision
import AVKit

@available(iOS 13.0, *)
class MLSaliencyViewController: MLBasedSystemViewController, CaptureImageDelegate {
    
    
    
    var observation: VNSaliencyImageObservation? {
        didSet {
            //todo
        }
    }
    
    let saliencyMaskLayer = CALayer()
    let salientObjectsLayer = CAShapeLayer()
    var salientObjectsPathTransform = CGAffineTransform.identity
    
    override func viewDidLoad() {
        super.viewDidLoad()
        capture.delegate = self
        videoLayer!.addSublayer(saliencyMaskLayer)
        salientObjectsLayer.fillColor = nil
        salientObjectsLayer.strokeColor = #colorLiteral(red: 1, green: 0.5781051517, blue: 0, alpha: 1)
        videoLayer!.addSublayer(salientObjectsLayer)

        let userDefaults = UserDefaults.standard
        userDefaults.register(defaults: [//change SaliencyType here objectnessBased or attentionBased
                                userDefaults.saliencyTypeKey : SaliencyType.objectnessBased.rawValue,
                                userDefaults.viewModelKey : ViewModel.combined.rawValue])
        updateLayersVisibility()
    }
    
    override func createRequest() -> VNRequest? {
        let type : SaliencyType = SaliencyType(rawValue:UserDefaults.standard.saliencyType)!
        switch type {
        case .attentionBased:
            return VNGenerateAttentionBasedSaliencyImageRequest()
        case .objectnessBased:
            return VNGenerateObjectnessBasedSaliencyImageRequest()
        }
        
    }
    
    override func processResults(result: [VNObservation]?) -> Void {
        guard let ret : [VNSaliencyImageObservation] = result as? [VNSaliencyImageObservation]  else {
            return
        }
        let path = createSalientObjectsBoundingBoxPath(from: ret.first!, transform: self.salientObjectsPathTransform)
        DispatchQueue.main.async {
            print(path)
            self.salientObjectsLayer.path = path
        }
//        let mask = createHeapMap(observation: ret.first!)
//        DispatchQueue.main.async {
//            self.saliencyMaskLayer.contents = mask
//        }
    }
    
    override func viewDidLayoutSubviews() {
        updateLayersGeometry()
        super.viewDidLayoutSubviews()
    }
    
    func createHeapMap(observation: VNSaliencyImageObservation) -> CGImage? {
        let pixelBuffer = observation.pixelBuffer
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let vector = CIVector(x: 0, y: 0, z: 0, w: 1)
        let saliencyImage = ciImage.applyingFilter("CIColorMatrix", parameters: ["inputBVector" : vector])
        return CIContext().createCGImage(saliencyImage, from: saliencyImage.extent)
    }
    
    func createSalientObjectsBoundingBoxPath(from observation: VNSaliencyImageObservation, transform:CGAffineTransform) -> CGPath {
        let path = CGMutablePath()
        if let salientObjects = observation.salientObjects {
            for object in salientObjects {
                let bbox = object.boundingBox
                path.addRect(bbox, transform: transform)
            }
        }
        return path
    }
    
     override func updateLayersGeometry() -> Void {
        if let baseLayer = videoLayer {
            let outputRect = CGRect(x: 0, y: 0, width: 1, height: 1)
            let videoRect = baseLayer.layerRectConverted(fromMetadataOutputRect: outputRect)
            saliencyMaskLayer.frame = videoRect
            salientObjectsLayer.frame = videoRect
            
            let scaleT = CGAffineTransform(scaleX: salientObjectsLayer.bounds.width, y: -salientObjectsLayer.bounds.height)
            let translateT = CGAffineTransform(translationX: 0, y: salientObjectsLayer.bounds.height)
            salientObjectsPathTransform = scaleT.concatenating(translateT)
        }
    }
    
    func updateLayersVisibility(){
        guard let model = ViewModel(rawValue: UserDefaults.standard.viewModel) else {
            return
        }
        
        let saliencyMaskOpacity: Float!
        switch model {
        case .combined:
            saliencyMaskOpacity = 0.75
        case .maskOnly:
            saliencyMaskOpacity = 1
        case .rectsOnly:
            saliencyMaskOpacity = 0
        }
        saliencyMaskLayer.opacity = saliencyMaskOpacity
    }
}

extension UserDefaults {
    var saliencyTypeKey: String {
        return "SaliencyType"
    }
    
    @objc var saliencyType : Int {
        get {
            return integer(forKey: saliencyTypeKey)
        }
        set {
            set(newValue, forKey: saliencyTypeKey)
        }
    }
    
    var viewModelKey : String {
        return "ViewModel"
    }
    
    @objc var viewModel : Int {
        get {
            return integer(forKey: viewModelKey)
        }
        set {
            set(newValue, forKey: viewModelKey)
        }
    }
    
}
