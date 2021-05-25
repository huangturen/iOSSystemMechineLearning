//
//  ViewController.swift
//  MachineLearningBasedSystem
//
//  Created by mabaoyan on 2021/5/24.
//

import UIKit
import Vision

class ViewController: UIViewController, CaptureImageDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let capture = MLCaputure.shared
        
        let layer = capture.captureLayer()
        capture.delegate = self
        layer.frame = view.frame;
        view.layer.addSublayer(layer)
    }

    
    
    func captureOutput(_ output: CVPixelBuffer) {
        print("hello")
    }
    
}

