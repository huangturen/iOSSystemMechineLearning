//
//  MLFaceDetectViewController.swift
//  MachineLearningBasedSystem
//
//  Created by mabaoyan on 2021/5/31.
//

import UIKit
import Vision

class MLFaceDetectViewController: MLBasedSystemViewController, CaptureImageDelegate {
    let boxLayer = CAShapeLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        capture.delegate = self
        boxLayer.frame = view.bounds
        boxLayer.fillColor = nil
        boxLayer.strokeColor = UIColor.orange.cgColor
        
        videoLayer?.addSublayer(boxLayer)
    }
    
    override func captureOutput(_ output: CVPixelBuffer) {
        guard let reqs = createRequests() else {
            return
        }
        
        let handler = VNImageRequestHandler.init(cvPixelBuffer: output, orientation: .right, options: [:])
        
        try? handler.perform(reqs)
    }
    
    func createRequests() -> [VNRequest]? {
        let request = VNDetectFaceLandmarksRequest.init(completionHandler: self.handleDetectedFaceAndLandmarks)

        return [ request ]

    }

    
    override func updateLayersGeometry() {
        if let baseLayer = videoLayer {
            let outputRect = CGRect(x: 0, y: 0, width: 1, height: 1)
            let videoRect = baseLayer.layerRectConverted(fromMetadataOutputRect: outputRect)
            boxLayer.frame = videoRect
        }
    }
    
    fileprivate func handleDetectedFaceAndLandmarks(request: VNRequest?, error: Error?) {
        if let _ = error as NSError? {
            return
        }
        
        guard let rets : [ VNFaceObservation ] = request?.results as? [ VNFaceObservation ] else {
            return
        }
        
        let pathT = CGAffineTransform(scaleX: boxLayer.bounds.width, y: -boxLayer.bounds.height)
        let transform = CGAffineTransform(translationX: 0, y: boxLayer.bounds.height)
        let path = CGMutablePath()

        DispatchQueue.main.async {
            for faceR in rets {
                let faceBounds = faceR.boundingBox.applying(pathT.concatenating(transform))
                path.addRect(faceBounds)
                self.boxLayer.path = path
                
                guard let landmarks = faceR.landmarks else {
                    continue
                }
                
                let landmarkLayer = CAShapeLayer()
                let landmarkPath = CGMutablePath()
                let affineTransform = CGAffineTransform(scaleX: faceBounds.width, y: faceBounds.height)

                let openLandmarkRegions : [VNFaceLandmarkRegion2D?] = [
                    landmarks.leftEyebrow,
                    landmarks.rightEyebrow,
                    landmarks.faceContour,
                    landmarks.noseCrest,
                    landmarks.medianLine
                ]

                let closedLandmarkRegions = [
                    landmarks.leftEye,
                    landmarks.rightEye,
                    landmarks.outerLips,
                    landmarks.innerLips,
                    landmarks.nose
                ].compactMap{ $0 }

                for openLandMarkRegion in openLandmarkRegions where openLandMarkRegion != nil {
                    landmarkPath.addPoints(in: openLandMarkRegion!,
                                           applying: affineTransform,
                                           closingWhenComplete: false)
                }

                for closedLandmarkRegion in closedLandmarkRegions {
                    landmarkPath.addPoints(in: closedLandmarkRegion,
                                           applying: affineTransform,
                                           closingWhenComplete: true)
                }

                landmarkLayer.path = landmarkPath
                landmarkLayer.lineWidth = 2
                landmarkLayer.strokeColor = UIColor.green.cgColor
                landmarkLayer.fillColor = nil
                landmarkLayer.shadowOpacity = 0.75
                landmarkLayer.shadowRadius = 4

//                landmarkLayer.anchorPoint = .zero
                landmarkLayer.frame = faceBounds
                landmarkLayer.transform = CATransform3DMakeScale(1, -1, 1)

                self.boxLayer.addSublayer(landmarkLayer)
            }
        }
    }
}

extension CGMutablePath {
    func addPoints(in landmarkRegion: VNFaceLandmarkRegion2D,
                   applying affineTransform: CGAffineTransform,
                   closingWhenComplete closePath: Bool) {
        let pointCount = landmarkRegion.pointCount
        
        guard pointCount > 1  else {
            return
        }
        
        self.addLines(between: landmarkRegion.normalizedPoints, transform: affineTransform)
        
        if closePath {
            self.closeSubpath()
        }
    }
}
