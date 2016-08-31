//
//  ShakeManager.swift
//  TestVoiceActions
//
//  Created by Le Tai on 8/25/16.
//  Copyright © 2016 Snowball. All rights reserved.
//

import CoreMotion
import AVFoundation

class ShakeManager: NSObject {
    
    let motionManager = CMMotionManager()
    
    var shakeLeft: (() -> Void)?
    var shakeRight: (() -> Void)?
    
    override init() {
        super.init()
        motionManager.deviceMotionUpdateInterval = 0.01
        motionManager.startDeviceMotionUpdatesToQueue(.mainQueue()) { (motion, error) in
            self.handlerGyro(motion!.rotationRate)
        }
    }
    
    ////////
    var beginingLeftTilt = false
    var beginingRightTilt = false
    var lastShakedDate = NSDate(timeIntervalSinceNow: -2)
    var beginTiltedDate = NSDate(timeIntervalSinceNow: -2)
    let thresholdFirstMove = 3.77
    let thresholdBackMove = 0.77
    
    func handlerGyro(rotation: CMRotationRate) {
        if fabs(rotation.z) > thresholdFirstMove && fabs(lastShakedDate.timeIntervalSinceNow) > 0.3 {
            if !beginingRightTilt && !beginingLeftTilt {
                beginTiltedDate = NSDate()
                if (rotation.z > 0) {
                    beginingLeftTilt = true
                    beginingRightTilt = false
                } else {
                    beginingLeftTilt = false
                    beginingRightTilt = true
                }
            }
        }
        
        if fabs(beginTiltedDate.timeIntervalSinceNow) >= 0.3 {
            beginingRightTilt = false
            beginingLeftTilt = false
        } else {
            if (fabs(rotation.z) > thresholdBackMove) {
                if beginingLeftTilt && rotation.z < 0 {
                    lastShakedDate = NSDate()
                    beginingRightTilt = false
                    beginingLeftTilt = false
                    shakeLeft?()
                } else if beginingRightTilt && rotation.z > 0 {
                    lastShakedDate = NSDate()
                    beginingRightTilt = false
                    beginingLeftTilt = false
                    shakeRight?()
                }
            }
        }
    }
    ////////
    
    
    class func vibrate() {
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setCategory(AVAudioSessionCategoryPlayback)
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
        //        try! audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
    }

}
