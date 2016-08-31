//
//  ViewController.swift
//  TestVoiceActions
//
//  Created by Le Tai on 8/18/16.
//  Copyright © 2016 Snowball. All rights reserved.
//

import UIKit
import AVFoundation
import ApiAI
import CoreMotion

class ViewController: UIViewController {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    let apiai = ApiAI()
    var request: AITextRequest!
    
    let motionManager = CMMotionManager()
    
    
    var recorder: AVAudioRecorder!
    var isRecording = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
        try! AVAudioSession.sharedInstance().setActive(true)
        
//        let configuration = AIDefaultConfiguration()
//        configuration.clientAccessToken = "92c296f96a0243c6b4dca728e73214c4"
//        apiai.configuration = configuration
//        
//        request = apiai.textRequest()
//        
//        request.query = ["hello"]
//        request.setCompletionBlockSuccess({ (request, response) in
//            let result = response["result"] as! [String: AnyObject]
//            let fulfillment = result["fulfillment"] as! [String: AnyObject]
//            let speech = fulfillment["speech"] as! String
//            UIAlertView(title: speech, message: nil, delegate: nil, cancelButtonTitle: "OK").show()
//            self.apiai.cancellAllRequests()
//        }) { (request, error) in
//            self.titleLabel.text = error.localizedDescription
//            self.apiai.cancellAllRequests()
//            
//        }
//        apiai.enqueue(request)
        
        
        
        motionManager.deviceMotionUpdateInterval = 0.01
        //        motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue()) { (motion, error) in
        //            if let error = error {
        //                debugPrint(error)
        //            } else {
        //                debugPrint(motion!.userAcceleration.y)
        //            }
        //        }
        motionManager.startDeviceMotionUpdatesToQueue(.mainQueue()) { (motion, error) in
            let acceleration = motion!.gravity
            let rotation = atan2(acceleration.x, acceleration.y) - M_PI
            self.imageView.transform = CGAffineTransformMakeRotation(CGFloat(rotation))
            self.titleLabel.text = String(format: "%0.1f", rotation)
            
//            debugPrint(String(format: "%0.1f", motion!.userAcceleration.x))
//            if motion?.userAcceleration.x < -1.0 {
//                self.navigationController?.popViewControllerAnimated(true)
//            }
        }
        
        
        
        ////////////
        proximitySensor()
        ////////////
        
        
        ////////////
        setupAudio()
        ////////////
        
        ////////////
        brighnessSetup()
        ////////////
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        ////////////
        tiltSetup()
        ////////////
    }
    
    @IBAction func tryAgain(button: UIButton) {
//        button.enabled = false

        
    }
    
    
    
    var motionDisplayLink: CADisplayLink!
    var motionLastYaw = 0.0
    
    var initialAttitude: CMAttitude!
    var showingPrompt = false
    let showPromptTrigger = 1.0
    let showAnswerTrigger = 0.8
}


extension ViewController {
    
    func proximitySensor() {
        let device = UIDevice.currentDevice()
        device.proximityMonitoringEnabled = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.proximityChanged(_:)), name: UIDeviceProximityStateDidChangeNotification, object: device)
    }
    
    func proximityChanged(notification: NSNotification) {
        let device = notification.object as! UIDevice
        if device.proximityState {
            debugPrint("abc")
            debugPrint(UIScreen.mainScreen().brightness)
            
        } else {
            debugPrint("edf")
            debugPrint(UIScreen.mainScreen().brightness)
        }
    }
}

extension ViewController {
    func setupAudio() {
        let audioSession:AVAudioSession = AVAudioSession.sharedInstance()
        try! audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
        try! audioSession.setActive(true)
        let documents: AnyObject = NSSearchPathForDirectoriesInDomains( NSSearchPathDirectory.DocumentDirectory,  NSSearchPathDomainMask.UserDomainMask, true)[0]
        let str = documents.stringByAppendingPathComponent("recordTest.caf")
        let url = NSURL.fileURLWithPath(str as String)
        let recordSettings: [String: AnyObject] = [
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 2,
            AVEncoderBitRateKey: 12800,
            AVLinearPCMBitDepthKey: 16,
            AVEncoderAudioQualityKey: AVAudioQuality.Max.rawValue
        ]
        recorder = try! AVAudioRecorder(URL: url, settings: recordSettings)
        recorder.prepareToRecord()
        recorder.meteringEnabled = true
        recorder.record()
        NSTimer.scheduledTimerWithTimeInterval(0.02, target: self, selector: #selector(ViewController.levelTimerCallback), userInfo: nil, repeats: true)
        
    }
    
    func levelTimerCallback() {
        recorder.updateMeters()
        
        if recorder.averagePowerForChannel(0) > -7 && isRecording {
            isRecording = false
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let alertController = UIAlertController(title: "Coooooool!", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (alertAction) -> Void in
                    self.isRecording = true
                }))
                self.presentViewController(alertController, animated: true, completion: nil)
            })
        }
    }
}


extension ViewController {
    func tiltSetup() {
//        motionManager.startDeviceMotionUpdatesUsingReferenceFrame(.XArbitraryCorrectedZVertical)
//        motionDisplayLink = CADisplayLink(target: self, selector: #selector(ViewController.motionRefresh))
//        motionDisplayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        
//        if motionManager.deviceMotionAvailable {
//            initialAttitude = CMAttitude()
//            
//            
//            
//            
//            motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue()) { (data: CMDeviceMotion?, error: NSError?) in
//                
//                guard let data = data else { return }
//                
//                debugPrint(String(format: "%0.2f", data.rotationRate.z))
        
                // translate the attitude
//                data.attitude.multiplyByInverseOfAttitude(self.initialAttitude)
//                
//                // calculate magnitude of the change from our initial attitude
//                let magnitude = self.magnitudeFromAttitude(data.attitude) ?? 0
//                
//                // show the prompt
//                if !self.showingPrompt && magnitude > self.showPromptTrigger {
//                    self.showingPrompt = true
//                    debugPrint("Next")
//                }
//                
//                // hide the prompt
//                if self.showingPrompt && magnitude < self.showAnswerTrigger {
//                    self.showingPrompt = false
//                    debugPrint("Previous")
//                }
//            }
//        }
        
    }
    
    func motionRefresh() {
        let yaw = self.motionManager.deviceMotion!.attitude.yaw
        _ = self.motionManager.deviceMotion!.attitude.quaternion
        
        if motionLastYaw == 0 {
            motionLastYaw = yaw
        }
        
        let q = 0.1   // process noise
        let r = 0.1   // sensor noise
        var p = 0.1   // estimated error
        var k = 0.5
        
        var x = self.motionLastYaw;
        p = p + q
        k = p / (p + r)
        x = x + k*(yaw - x)
        p = (1 - k)*p
        self.motionLastYaw = x
        
        debugPrint(x)

    }
    
    func magnitudeFromAttitude(attitude: CMAttitude) -> Double {
        return sqrt(pow(attitude.roll, 2) + pow(attitude.yaw, 2) + pow(attitude.pitch, 2))
    }
}



extension ViewController {
    func brighnessSetup() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.brightnessChange(_:)), name: UIScreenBrightnessDidChangeNotification, object: nil)
    }
    
    func brightnessChange(notification: NSNotification) {
        debugPrint(UIScreen.mainScreen().brightness)
    }
}

