//
//  AVAsset.swift
//  TestVoiceActions
//
//  Created by Le Tai on 9/1/16.
//  Copyright © 2016 Snowball. All rights reserved.
//

import AVFoundation
import UIKit

extension AVAsset {
    func previewImageAtTime(time: CMTime = kCMTimeZero) -> UIImage? {
        let imageGenerator = AVAssetImageGenerator(asset: self)
        imageGenerator.appliesPreferredTrackTransform = true
        do {
            let imageRef = try imageGenerator.copyCGImageAtTime(time, actualTime: nil)
            return UIImage(CGImage: imageRef)
        } catch let error as NSError {
            print("Image generation failed with error \(error)")
            return nil
        }
    }
}
