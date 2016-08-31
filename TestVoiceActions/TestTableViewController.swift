//
//  TestTableViewController.swift
//  TestVoiceActions
//
//  Created by Le Tai on 8/18/16.
//  Copyright © 2016 Snowball. All rights reserved.
//

import UIKit
import CoreMotion
import AudioToolbox
import AVFoundation

class TestTableViewController: UITableViewController {
    
    var currentIndex = 0
    let motionManager = CMMotionManager()
    var scrollable = true
    
    
    var shakeManager: ShakeManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.scrollEnabled = false
        
        motionManager.deviceMotionUpdateInterval = 0.01
        motionManager.startDeviceMotionUpdatesToQueue(.mainQueue()) { (motion, error) in
//            self.handleDeviceMotion(motion!.userAcceleration)
        }
//
//        motionManager.startAccelerometerUpdatesToQueue(.mainQueue()) { (data, error) in
//            self.handleAccelerometer(data!.acceleration)
//        }
        
//        motionManager.startGyroUpdatesToQueue(.mainQueue()) { (data, error) in
//            self.handlerGyro(data!.rotationRate)
//        }
        
    }
    
    
    func handleDeviceMotion(userAcceleration: CMAcceleration) {
        if userAcceleration.x < -1.0 && self.scrollable {
            if self.currentIndex < 4 {
                self.scrollable = false
                self.currentIndex = self.currentIndex + 1
                let indexPath = NSIndexPath(forRow: self.currentIndex, inSection: 0)
                self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .None, animated: true)
            } else {
                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
            }
        } else {
            self.scrollable = true
        }
    }
    
    
    ////////
    var shake = false
    var totalG = 0.0
    func handleAccelerometer(aceler: CMAcceleration) {
        if (aceler.x > 1.5) {
            shake = true
            NSTimer.scheduledTimerWithTimeInterval(0.75, target: self, selector: #selector(TestTableViewController.endShake), userInfo: nil, repeats: false)
            return
        }
        
        if(shake) {
            totalG += aceler.x
        }
    }
    func endShake() {
        shake = false
        var direction = 0
        if totalG < 0 {
            direction = 1
            next()
        }
        
        if totalG > 0 {
            direction = -1
            previous()
        }
        
        totalG = 0
    }
    ////////
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        currentIndex = 0
        
        shakeManager = ShakeManager()
        shakeManager.shakeLeft = {
            self.previous()
        }
        shakeManager.shakeRight = {
            self.next()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        shakeManager = nil
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return view.frame.height
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TableViewCell", forIndexPath: indexPath) as! TableViewCell
        cell.flightImageView.image = UIImage(named: "\(indexPath.row + 1).jpg")
        return cell
    }
}


extension TestTableViewController {
    func previous() {
        if self.currentIndex > 0 {
            self.currentIndex = self.currentIndex - 1
            let indexPath = NSIndexPath(forRow: self.currentIndex, inSection: 0)
            self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .None, animated: true)
        } else {
            ShakeManager.vibrate()
        }
    }
    
    func next() {
        if self.currentIndex < 4 {
            self.currentIndex = self.currentIndex + 1
            let indexPath = NSIndexPath(forRow: self.currentIndex, inSection: 0)
            self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .None, animated: true)
        } else {
            ShakeManager.vibrate()
        }
    }
}

class TableViewCell: UITableViewCell {
    @IBOutlet weak var flightImageView: UIImageView!
    

}
