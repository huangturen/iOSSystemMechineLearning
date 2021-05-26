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
    override func viewDidLoad() {
        super.viewDidLoad()
        capture.delegate = self
        videoLayer!.addSublayer(saliencyMaskLayer)
        let userDefaults = UserDefaults.standard
        userDefaults.register(defaults: [
                                userDefaults.saliencyTypeKey : SaliencyType.attentionBased.rawValue,
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
        
        let mask = createHeapMap(observation: ret.first!)
        saliencyMaskLayer.contents = mask
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
    
     override func updateLayersGeometry() -> Void {
        if let baseLayer = videoLayer {
            let outputRect = CGRect(x: 0, y: 0, width: 1, height: 1)
            let videoRect = baseLayer.layerRectConverted(fromMetadataOutputRect: outputRect)
            saliencyMaskLayer.frame = videoRect
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
