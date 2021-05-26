//
//  MLVisionSaliency.swift
//  MachineLearningBasedSystem
//
//  Created by mabaoyan on 2021/5/26.
//

import Foundation
import Vision
import CoreVideo
import CoreImage

public enum SaliencyType: Int {
    case attentionBased = 0
    case objectnessBased
}

public enum ViewModel : Int {
    case combined = 0
    case rectsOnly
    case maskOnly
}
