//
//  MLImageRegistrationViewController2.swift
//  MachineLearningBasedSystem
//
//  Created by mabaoyan on 2021/5/27.
//

import UIKit
import Vision

class MLImageRegistrationViewController2: MLBasedSystemViewController, CaptureImageDelegate {
    
    private let sceneStablityRequestHandler = VNSequenceRequestHandler()
    private var sceneStablityHistoryPoints = [CGPoint]()
    private let label = UILabel.init()
    var previousBuffer : CVPixelBuffer?
    
    enum sceneStablityResult {
        case unknown
        case stable
        case unstable
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        capture.delegate = self
        view.addSubview(label)
        label.frame = CGRect(x: 0, y: view.bounds.height - 100, width: view.bounds.width, height: 20)
        label.textColor = .black
        label.textAlignment = .center
    }
    
    override func captureOutput(_ output: CVPixelBuffer) {
        if nil == self.previousBuffer {
            self.previousBuffer = output
            return
        }
        
        let request = createRequest(buffer: output)
        guard let _ = request else {
            return
        }
        try? sceneStablityRequestHandler.perform([ request! ], on: self.previousBuffer!, orientation: .up)
        self.previousBuffer = output
        processResults(result: request!.results as? [VNObservation])
    }
    
    func createRequest(buffer: CVPixelBuffer ) -> VNRequest? {
        return VNTranslationalImageRegistrationRequest.init(targetedCVPixelBuffer: buffer, orientation: .up, options: [:])
    }
    
    override func processResults(result: [VNObservation]?) {
        guard let ret : VNImageTranslationAlignmentObservation = result?.first as?   VNImageTranslationAlignmentObservation  else {
            return
        }
        
        let transform = ret.alignmentTransform
        self.sceneStablityHistoryPoints.append(CGPoint(x: transform.tx, y: transform.ty))
        DispatchQueue.main.async {
            switch self.sceneStability {
                case .stable:
                    self.label.text = "stable"
                case .unstable:
                    self.label.text = "unstable"
                    self.previousBuffer = nil
                    self.sceneStablityHistoryPoints.removeAll()
                case .unknown:
                    let _ = self.sceneStablityHistoryPoints
            }
        }
    }
    
    var sceneStability: sceneStablityResult {
        guard sceneStablityHistoryPoints.count > 15 else {
            return .unknown
        }
        
        var movingAverage = CGPoint.zero
        movingAverage.x = sceneStablityHistoryPoints.map{ $0.x }.reduce(.zero, +)
        movingAverage.y = sceneStablityHistoryPoints.map{ $0.y }.reduce(.zero, +)
        
        let distance = abs(movingAverage.x) + abs(movingAverage.y)
        return (distance < 10 ?  .stable : .unstable)
    }
}

