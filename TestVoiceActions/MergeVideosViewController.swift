//
//  MergeVideosViewController.swift
//  TestVoiceActions
//
//  Created by Le Tai on 8/29/16.
//  Copyright © 2016 Snowball. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary
import Photos
import AVKit

class MergeVideosViewController: UIViewController {
    
    @IBOutlet weak var simpleMergeButton: UIButton!
    @IBOutlet weak var backgroundAudioMergeButton: UIButton!
    @IBOutlet weak var saveToLibrarySwitch: UISwitch!
    @IBOutlet weak var awesomeMergedVideoButton: UIButton!
    
    let DefaultVideoItemSize = CGSize(width: 720, height: 1280)
    let ExportedVideoSize = CGSize(width: 854, height: 480)
    
    let font1 = UIFont(name: "ITC Avant Garde Gothic Std", size: 28)!
    
    var blankVideoAsset: AVAsset!
    var audioAsset: AVAsset!
    var assets: [AVAsset] = []
    var tracks: [AVMutableCompositionTrack] = []
    
    let loadingVC = UIAlertController.loadingVC()
    let playerController = AVPlayerViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Load asset
        loadAssets()
    }
}

extension MergeVideosViewController {
    
    @IBAction func exportVideos(button: UIButton) {
        presentViewController(loadingVC, animated: true, completion: nil)
        mergeVideos(hasBGAudio: false,
                    hasAnimations: false,
                    hasTextEffects: false,
                    fixRotate: true) { (asset, url, error) in
                        self.handler(asset, url: url, error: error)
        }
    }
    
    @IBAction func exportVideosWithBGAudio(button: UIButton) {
        presentViewController(loadingVC, animated: true, completion: nil)
        mergeVideos(hasBGAudio: true,
                    hasAnimations: false,
                    hasTextEffects: false,
                    fixRotate: true) { (asset, url, error) in
                        self.handler(asset, url: url, error: error)
        }
    }
    
    @IBAction func exportVideosWithAnimation(button: UIButton) {
        presentViewController(loadingVC, animated: true, completion: nil)
        mergeVideos(hasBGAudio: true, hasAnimations: true, hasTextEffects: false, fixRotate: true) { (asset, url, error) in
            self.handler(asset, url: url, error: error)
        }
    }
    
    @IBAction func exportVideosWithTexts(button: UIButton) {
        presentViewController(loadingVC, animated: true, completion: nil)
        mergeVideos(hasBGAudio: true,
                    hasAnimations: true,
                    hasTextEffects: true,
                    fixRotate: true) { (asset, url, error) in
                        self.handler(asset, url: url, error: error)
        }
    }
    
    @IBAction func awesomeMergedVideoButtonTapped(button: UIButton) {
        presentViewController(loadingVC, animated: true, completion: nil)
        
        let videoItemSize = CGSize(width: DefaultVideoItemSize.width * ExportedVideoSize.height / DefaultVideoItemSize.height, height: ExportedVideoSize.height)
        debugPrint("Video item size: \(videoItemSize)")
        
        //        let bgAudioTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        //        try! bgAudioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, audioAsset.duration), ofTrack: audioAsset.tracksWithMediaType(AVMediaTypeAudio)[0], atTime: kCMTimeZero)
        //        let audioLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: bgAudioTrack)
        //        layerInstructions.append(audioLayerInstruction)
        
        //        let emptyTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        //        atTime = CMTimeAdd(atTime, CMTime(seconds: 17, preferredTimescale: kCMTimeZero.timescale))
        //        emptyTrack.insertEmptyTimeRange(CMTimeRange(start: kCMTimeZero, duration: atTime))
        
        //        let blankTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        //        try! blankTrack.insertTimeRange(CMTimeRange(start: kCMTimeZero, duration: CMTimeMake(2, kCMTimeZero.timescale)), ofTrack: blankTrack, atTime: kCMTimeZero)
        //        let blankInstruction = videoCompositionInstructionForTrack(blankTrack,
        //                                                                   asset: blankVideoAsset,
        //                                                                   fixRotate: true,
        //                                                                   targetSize: videoItemSize)
        //        layerInstructions.append(blankInstruction)
        
        
        
        
        //        let tienAsset = assets[0]
        //        let tienTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        //        try! tienTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, tienAsset.duration), ofTrack: tienAsset.tracksWithMediaType(AVMediaTypeVideo)[0], atTime: kCMTimeZero)
        //        let tienInstruction = videoCompositionInstructionForTrack(tienTrack,
        //                                                                  asset: tienAsset,
        //                                                                  fixRotate: true,
        //                                                                  targetSize: videoItemSize)
        ////        tienInstruction.setOpacity(0.0, atTime: atTime)
        //        layerInstructions.append(tienInstruction)
        
        
        
        
        
        ////////////////////////////////////////////////
        
        //        let tienAsset = assets[0]
        //        let tienTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        //        try! tienTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, tienAsset.duration), ofTrack: tienAsset.tracksWithMediaType(AVMediaTypeVideo)[0], atTime: atTime)
        //        let tienLayerInstruction = videoCompositionInstructionForTrack(tienTrack,
        //                                                                       asset: tienAsset,
        //                                                                       fixRotate: true,
        //                                                                       targetSize: videoItemSize)
        //        tienLayerInstruction.setOpacity(0.0, atTime: atTime)
        
        ////////////////////////////////////////////////
        ////////////////////////////////////////////////
        var layerInstructions: [AVVideoCompositionLayerInstruction] = []
        let mixComposition = AVMutableComposition()
        var atTime: CMTime = kCMTimeZero
        
        ////////////////////////////////////////////////
        ////////////////////////////////////////////////
        
        
        //////////////// Add Sence /////////////////
        ///////////////////////////////////////////////
        
        let parentLayer = CALayer()
        parentLayer.frame = CGRectMake(0, 0, ExportedVideoSize.width, ExportedVideoSize.height)
        
        let backgroundLayer = CALayer()
        backgroundLayer.backgroundColor = UIColor.whiteColor().CGColor
        backgroundLayer.frame = CGRect(origin: .zero, size: ExportedVideoSize)
        
        parentLayer.addSublayer(backgroundLayer)
        
        let videoLayer = CALayer()
        videoLayer.backgroundColor = UIColor.clearColor().CGColor
        videoLayer.frame = CGRect(origin: .zero, size: ExportedVideoSize)
        parentLayer.addSublayer(videoLayer)
        
        
        let textFontSize1: CGFloat = 60
        ////////////////////////////////////////////////
        addCenterTextSence(composition: mixComposition,
                           layerInstructions: &layerInstructions,
                           atTime: &atTime,
                           size: videoItemSize,
                           parentLayer: parentLayer,
                           backgroundColor: UIColor(red: 228/255, green: 63/255, blue: 107/255, alpha: 1),
                           textColor: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1),
                           text: "smile.",
                           textFont: font1,
                           textFontSize: textFontSize1,
                           isFirstScene: true)
        ////////////////////////////////////////////////
        
        ////////////////////////////////////////////////
        addCenterTextSence(composition: mixComposition,
                           layerInstructions: &layerInstructions,
                           atTime: &atTime,
                           size: videoItemSize,
                           parentLayer: parentLayer,
                           backgroundColor: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1),
                           textColor: UIColor(red: 110/255, green: 96/255, blue: 255/255, alpha: 1),
                           text: "cry.",
                           textFont: font1,
                           textFontSize: textFontSize1)
        ////////////////////////////////////////////////
        
        
        
        ////////////////////////////////////////////////
        addCenterTextSence(composition: mixComposition,
                           layerInstructions: &layerInstructions,
                           atTime: &atTime,
                           size: videoItemSize,
                           parentLayer: parentLayer,
                           backgroundColor: UIColor(red: 90/255, green: 214/255, blue: 219/255, alpha: 1),
                           textColor: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1),
                           text: "surprise.",
                           textFont: font1,
                           textFontSize: textFontSize1)
        ////////////////////////////////////////////////
        
        
        
        ////////////////////////////////////////////////
        addCenterTextSence(composition: mixComposition,
                           layerInstructions: &layerInstructions,
                           atTime: &atTime,
                           size: videoItemSize,
                           parentLayer: parentLayer,
                           backgroundColor: UIColor(red: 237/255, green: 207/255, blue: 61/255, alpha: 1),
                           textColor: UIColor(red: 255/255, green: 66/255, blue: 102/255, alpha: 1),
                           text: "excited.",
                           textFont: font1,
                           textFontSize: textFontSize1)
        ////////////////////////////////////////////////
        
        
        
        ////////////////////////////////////////////////
        addCenterTextSence(composition: mixComposition,
                           layerInstructions: &layerInstructions,
                           atTime: &atTime,
                           size: videoItemSize,
                           parentLayer: parentLayer,
                           backgroundColor: UIColor(red: 228/255, green: 63/255, blue: 107/255, alpha: 1),
                           textColor: UIColor(red: 240/255, green: 206/255, blue: 65/255, alpha: 1),
                           text: "hectic.",
                           textFont: font1,
                           textFontSize: textFontSize1)
        ////////////////////////////////////////////////
        
        
        
        
        ////////////////////////////////////////////////
        let (allAreLayer, allAreTextLayer) = addCenterTextSence(composition: mixComposition,
                                                                layerInstructions: &layerInstructions,
                                                                atTime: &atTime,
                                                                size: videoItemSize,
                                                                parentLayer: parentLayer,
                                                                backgroundColor: UIColor(red: 102/255, green: 98/255, blue: 255/255, alpha: 1),
                                                                textColor: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1),
                                                                text: "all are",
                                                                textFont: font1,
                                                                textFontSize: textFontSize1,
                                                                hideWhenEnd: false)
        ////////////////////////////////////////////////
        
        
        
        ////////////////////////////////////////////////
        addBlankLayerInstruction(composition: mixComposition,
                                 atTime: &atTime,
                                 layerInstructions: &layerInstructions,
                                 size: videoItemSize,
                                 atTimeWillChange: {
                                    
                                    let reactionsTextLayer = CATextLayer()
                                    reactionsTextLayer.string = "reactions"
                                    reactionsTextLayer.font = self.font1
                                    reactionsTextLayer.fontSize = textFontSize1
                                    reactionsTextLayer.frame = CGRect(x: 0,
                                        y: parentLayer.frame.height/2 - 10 - textFontSize1,
                                        width: parentLayer.bounds.width,
                                        height: reactionsTextLayer.fontSize + 10)
                                    reactionsTextLayer.position = CGPoint(x: allAreLayer.frame.width/2,
                                        y: allAreLayer.frame.height/2 - reactionsTextLayer.frame.height)
                                    reactionsTextLayer.alignmentMode = kCAAlignmentCenter
                                    reactionsTextLayer.foregroundColor = UIColor(red: 90/255, green: 216/255, blue: 218/255, alpha: 1).CGColor
                                    reactionsTextLayer.opacity = 0.0
                                    
                                    allAreLayer.addSublayer(reactionsTextLayer)
                                    
                                    self.moveLayer(allAreTextLayer,
                                        duration: 0.25,
                                        beginTime: atTime.seconds,
                                        fromCenterPoint: allAreTextLayer.position,
                                        toCenterPoint: CGPoint(x: allAreTextLayer.frame.width/4 - 50, y: allAreTextLayer.position.y))
                                    
                                    self.hideLayer(reactionsTextLayer, hidden: false, duration: 0, beginTime: atTime.seconds)
                                    self.moveLayer(reactionsTextLayer,
                                        duration: 0.25,
                                        beginTime: atTime.seconds,
                                        fromCenterPoint: reactionsTextLayer.position,
                                        toCenterPoint: CGPoint(x: allAreLayer.frame.width/2, y: allAreLayer.frame.height/2))
                                    
            }, atTimeDidChange: nil)
        
        addBlankLayerInstruction(composition: mixComposition,
                                 atTime: &atTime,
                                 layerInstructions: &layerInstructions,
                                 size: videoItemSize,
                                 atTimeWillChange: {
                                    let withTextLayer = CATextLayer()
                                    withTextLayer.string = "with"
                                    withTextLayer.font = self.font1
                                    withTextLayer.fontSize = textFontSize1
                                    withTextLayer.frame = CGRect(x: 0,
                                        y: parentLayer.frame.height/2 - 10 - textFontSize1,
                                        width: allAreLayer.bounds.width,
                                        height: withTextLayer.fontSize + 10)
                                    withTextLayer.position = CGPoint(x: withTextLayer.frame.width/2 + withTextLayer.frame.width,
                                        y: allAreLayer.frame.height/2)
                                    withTextLayer.alignmentMode = kCAAlignmentCenter
                                    withTextLayer.foregroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1).CGColor
                                    withTextLayer.opacity = 0.0
                                    allAreLayer.addSublayer(withTextLayer)
                                    self.hideLayer(withTextLayer, hidden: false, duration: 0, beginTime: atTime.seconds)
                                    self.moveLayer(withTextLayer,
                                        duration: 0.25,
                                        beginTime: atTime.seconds,
                                        fromCenterPoint: withTextLayer.position,
                                        toCenterPoint: CGPoint(x: allAreLayer.frame.width*3/4 + 20, y: withTextLayer.position.y))
            }, atTimeDidChange: nil)
        ////////////////////////////////////////////////
        
        
        
        ////////////////////////////////////////////////
        addBlankLayerInstruction(composition: mixComposition,
                                 atTime: &atTime,
                                 layerInstructions: &layerInstructions,
                                 size: videoItemSize,
                                 atTimeWillChange: {
                                    self.moveLayer(allAreLayer,
                                        duration: 0.25,
                                        beginTime: atTime.seconds,
                                        fromCenterPoint: allAreLayer.position,
                                        toCenterPoint: CGPoint(x: -allAreLayer.frame.width, y: allAreLayer.position.y))
                                    
                                    let promptImage = UIImage(named: "prompts6.png")!.resizeImage(newHeight: videoItemSize.height)
                                    let promptImageLayer = CALayer()
                                    promptImageLayer.contents = promptImage.CGImage
                                    promptImageLayer.frame = CGRect(origin: .zero, size: promptImage.size)
                                    promptImageLayer.masksToBounds = true
                                    
                                    let promptLayer = CALayer()
                                    promptLayer.frame = CGRect(origin: CGPoint(x: parentLayer.frame.width, y: 0), size: promptLayer.frame.size)
                                    promptLayer.addSublayer(promptImageLayer)
                                    
                                    parentLayer.addSublayer(promptLayer)
                                    
                                    self.hideLayer(promptImageLayer,
                                        hidden: false,
                                        duration: 0,
                                        beginTime: atTime.seconds)
                                    self.moveLayer(promptLayer,
                                        duration: 0.25,
                                        beginTime: atTime.seconds,
                                        fromCenterPoint: promptLayer.position,
                                        toCenterPoint: CGPoint(x: parentLayer.frame.width/2, y: parentLayer.frame.height/2))
            },
                                 atTimeDidChange: {
                                    self.hideLayer(allAreLayer,
                                        hidden: true,
                                        duration: 0,
                                        beginTime: atTime.seconds)
        })
        ////////////////////////////////////////////////
        
        
        ////////////////////////////////////////////////
        ////////////////////////////////////////////////
        
        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTime(seconds: 120, preferredTimescale: kCMTimeZero.timescale))
        mainInstruction.layerInstructions = layerInstructions
        
        let renderSize = ExportedVideoSize
        let mainComposition = AVMutableVideoComposition()
        mainComposition.instructions = [mainInstruction]
        mainComposition.frameDuration = CMTimeMake(1, 30)
        mainComposition.renderSize = renderSize
        
        mainComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, inLayer: parentLayer)
        ////////////////////////////////////////////////
        ////////////////////////////////////////////////
        
        /// Create output url
        let outputURL = getSavePathURL()
        
        /// Create export
        let exported = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)!
        exported.videoComposition = mainComposition
        exported.outputURL = outputURL
        exported.outputFileType = AVFileTypeQuickTimeMovie
        exported.shouldOptimizeForNetworkUse = true
        
        /// Perform the export
        exported.exportAsynchronouslyWithCompletionHandler {
            dispatch_async(dispatch_get_main_queue()) { _ in
                switch exported.status {
                case .Unknown, .Waiting, .Exporting, .Failed, .Cancelled:
                    debugPrint("Failed")
                    debugPrint(exported.error)
                    self.handler(nil, url: nil, error: exported.error)
                case .Completed:
                    if self.saveToLibrarySwitch.on {
                        PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                            PHAssetChangeRequest.creationRequestForAssetFromVideoAtFileURL(outputURL)
                            }, completionHandler: nil)
                    }
                    let asset = AVAsset(URL: outputURL)
                    self.handler(asset, url: outputURL, error: nil)
                }
            }
        }
    }
    
    private func addLayerInstruction(layerInstruction: AVMutableVideoCompositionLayerInstruction,
                                     inout layerInstructions: [AVVideoCompositionLayerInstruction],
                                           inout atTime: CMTime,
                                                 duration: CMTime) {
        atTime = CMTimeAdd(atTime, duration)
        layerInstruction.setOpacity(0.0, atTime: atTime)
        layerInstructions.append(layerInstruction)
    }
    
    private func hideLayer(layer: CALayer,
                           hidden: Bool,
                           duration: CFTimeInterval,
                           beginTime: CFTimeInterval) {
        let fromValue = hidden ? 1.0 : 0.0
        let toValue = hidden ? 0.0 : 1.0
        let beginTime = beginTime == 0.0 ? AVCoreAnimationBeginTimeAtZero : beginTime
        let hideAnimation = CABasicAnimation(keyPath: "opacity")
        hideAnimation.duration = duration
        hideAnimation.removedOnCompletion = false
        hideAnimation.fromValue = fromValue
        hideAnimation.toValue = toValue
        hideAnimation.beginTime = beginTime
        hideAnimation.fillMode = kCAFillModeForwards
        layer.addAnimation(hideAnimation, forKey: "animateOpacity\(NSDate().timeIntervalSince1970)")
    }
    
    
    private func moveLayer(layer: CALayer,
                           duration: CFTimeInterval,
                           beginTime: CFTimeInterval,
                           fromCenterPoint: CGPoint,
                           toCenterPoint: CGPoint) {
        let beginTime = beginTime == 0.0 ? AVCoreAnimationBeginTimeAtZero : beginTime
        let hideAnimation = CABasicAnimation(keyPath: "position")
        hideAnimation.duration = duration
        hideAnimation.removedOnCompletion = false
        hideAnimation.fromValue = NSValue(CGPoint: fromCenterPoint)
        hideAnimation.toValue = NSValue(CGPoint: toCenterPoint)
        hideAnimation.beginTime = beginTime
        hideAnimation.fillMode = kCAFillModeForwards
        layer.addAnimation(hideAnimation, forKey: "animatePosition\(NSDate().timeIntervalSince1970)")
    }
    
    private func blankCenterTextLayer(backgroundColor backgroundColor: UIColor,
                                                      frame: CGRect,
                                                      text: String,
                                                      textColor: UIColor,
                                                      textFont: UIFont,
                                                      textFontSize: CGFloat) -> (layer: CALayer, textLayer: CATextLayer) {
        let layer = CALayer()
        layer.backgroundColor = backgroundColor.CGColor
        layer.frame = frame
        
        let textLayer = CATextLayer()
        textLayer.string = text
        textLayer.font = textFont
        textLayer.fontSize = textFontSize
        textLayer.frame = CGRect(x: 0,
                                 y: layer.frame.height/2 - 10,
                                 width: layer.bounds.width,
                                 height: textLayer.fontSize + 10)
        textLayer.position = CGPoint(x: frame.width/2, y: frame.height/2)
        textLayer.alignmentMode = kCAAlignmentCenter
        textLayer.foregroundColor = textColor.CGColor
        layer.addSublayer(textLayer)
        
        return (layer, textLayer)
    }
    
    private func addBlankLayerInstruction(composition composition: AVMutableComposition,
                                                      inout atTime: CMTime,
                                                            inout layerInstructions: [AVVideoCompositionLayerInstruction],
                                                                  size: CGSize,
                                                                  atTimeWillChange: (() -> Void)?,
                                                                  atTimeDidChange: (() -> Void)?) {
        let blankTrack = composition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        try! blankTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, blankVideoAsset.duration), ofTrack: blankVideoAsset.tracksWithMediaType(AVMediaTypeVideo)[0], atTime: atTime)
        let layerInstruction = videoCompositionInstructionForTrack(blankTrack,
                                                                   asset: blankVideoAsset,
                                                                   fixRotate: true,
                                                                   targetSize: size)
        
        atTimeWillChange?()
        
        atTime = CMTimeAdd(atTime, blankVideoAsset.duration)
        layerInstruction.setOpacity(0.0, atTime: atTime)
        layerInstructions.append(layerInstruction)
        
        atTimeDidChange?()
    }
    
    
    private func addCenterTextSence(composition composition: AVMutableComposition,
                                                inout layerInstructions: [AVVideoCompositionLayerInstruction],
                                                      inout atTime: CMTime,
                                                            size: CGSize,
                                                            parentLayer: CALayer,
                                                            backgroundColor: UIColor,
                                                            textColor: UIColor,
                                                            text: String,
                                                            textFont: UIFont,
                                                            textFontSize: CGFloat,
                                                            hideWhenEnd: Bool = true,
                                                            isFirstScene: Bool = false) -> (backgroundLayer: CALayer, textLayer: CATextLayer) {
        
        var result: (layer: CALayer, textLayer: CATextLayer)!
        
        addBlankLayerInstruction(composition: composition,
                                 atTime: &atTime,
                                 layerInstructions: &layerInstructions,
                                 size: size,
                                 atTimeWillChange: {
                                    result = self.blankCenterTextLayer(backgroundColor: backgroundColor,
                                        frame: parentLayer.bounds,
                                        text: text,
                                        textColor: textColor,
                                        textFont: textFont,
                                        textFontSize: textFontSize)
                                    parentLayer.addSublayer(result.layer)
                                    if !isFirstScene {
                                        result.layer.opacity = 0.0
                                    }
                                    self.hideLayer(result.layer, hidden: false, duration: 0, beginTime: atTime.seconds)
            },
                                 atTimeDidChange: {
                                    if hideWhenEnd {
                                        self.hideLayer(result.layer, hidden: true, duration: 0, beginTime: atTime.seconds)
                                    }
        })
        
        return (result.layer, result.textLayer)
    }
}


extension MergeVideosViewController {
    private func handler(asset: AVAsset?, url: NSURL?, error: NSError?) {
        self.loadingVC.dismissViewControllerAnimated(true, completion: { _ in
            if let url = url {
                let player = AVPlayer(URL: url)
                self.playerController.player = player
                self.presentViewController(self.playerController, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: error?.localizedDescription, message: nil, preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        })
    }
    
    private func mergeVideos(hasBGAudio hasBGAudio: Bool,
                                        hasAnimations: Bool,
                                        hasTextEffects: Bool,
                                        fixRotate: Bool,
                                        completion: (AVAsset?, NSURL?, NSError?) -> Void) {
        
        /// Video tracks
        var atTime: CMTime = kCMTimeZero
        var layerInstructions: [AVVideoCompositionLayerInstruction] = []
        let mixComposition = AVMutableComposition()
        
        
        for (index, asset) in assets.enumerate() {
            let videoTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
            try! videoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, asset.duration), ofTrack: asset.tracksWithMediaType(AVMediaTypeVideo)[0], atTime: atTime)
            
            let audioTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
            try! audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, asset.duration), ofTrack: asset.tracksWithMediaType(AVMediaTypeAudio)[0], atTime: atTime)
            
            atTime = CMTimeAdd(atTime, asset.duration)
            
            let instruction = videoCompositionInstructionForTrack(videoTrack,
                                                                  asset: asset,
                                                                  fixRotate: fixRotate,
                                                                  targetSize: DefaultVideoItemSize) //TODO:
            if index < assets.count - 1 {
                instruction.setOpacity(0.0, atTime: atTime)
            }
            layerInstructions.append(instruction)
        }
        
        if hasBGAudio {
            let bgAudioTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
            try! bgAudioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, atTime), ofTrack: audioAsset.tracksWithMediaType(AVMediaTypeAudio)[0], atTime: kCMTimeZero)
        }
        
        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, totalDurations(assets))
        mainInstruction.layerInstructions = layerInstructions
        
        let renderSize = DefaultVideoItemSize
        let mainComposition = AVMutableVideoComposition()
        mainComposition.instructions = [mainInstruction]
        mainComposition.frameDuration = CMTimeMake(1, 30)
        mainComposition.renderSize = renderSize
        
        applyVideoEffectsToComposition(mainComposition,
                                       size: renderSize,
                                       hasAnimations: hasAnimations,
                                       hasTextEffects: hasTextEffects)
        
        /// Create output url
        let outputURL = getSavePathURL()
        
        /// Create export
        let exported = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)!
        exported.videoComposition = mainComposition
        exported.outputURL = outputURL
        exported.outputFileType = AVFileTypeQuickTimeMovie
        exported.shouldOptimizeForNetworkUse = true
        
        /// Perform the export
        exported.exportAsynchronouslyWithCompletionHandler {
            dispatch_async(dispatch_get_main_queue()) { _ in
                switch exported.status {
                case .Unknown, .Waiting, .Exporting, .Failed, .Cancelled:
                    debugPrint("Failed")
                    debugPrint(exported.error)
                    dispatch_async(dispatch_get_main_queue(), {
                        completion(nil, nil, exported.error)
                    })
                case .Completed:
                    dispatch_async(dispatch_get_main_queue(), {
                        if self.saveToLibrarySwitch.on {
                            PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                                PHAssetChangeRequest.creationRequestForAssetFromVideoAtFileURL(outputURL)
                                }, completionHandler: nil)
                        }
                        completion(AVAsset(URL: outputURL), outputURL, nil)
                    })
                }
            }
        }
    }
    
    private func loadAssets() {
        let firstURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("1", ofType: "mp4")!)
        assets.append(AVAsset(URL: firstURL))
        
        let secondURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("2", ofType: "mp4")!)
        assets.append(AVAsset(URL: secondURL))
        
        let thirdURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("3", ofType: "mp4")!)
        assets.append(AVAsset(URL: thirdURL))
        
        let fourthURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("4", ofType: "mp4")!)
        assets.append(AVAsset(URL: fourthURL))
        
        let fifthURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("5", ofType: "mp4")!)
        assets.append(AVAsset(URL: fifthURL))
        
        let audioURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("audio", ofType: "mp3")!)
        audioAsset = AVAsset(URL: audioURL)
        
        let blankVideoURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("blank", ofType: "mp4")!)
        blankVideoAsset = AVAsset(URL: blankVideoURL)
    }
    
    private func totalDurations(assets: [AVAsset]) -> CMTime {
        var time: CMTime = kCMTimeZero
        for duration in assets.flatMap({ $0.duration }) {
            time = CMTimeAdd(time, duration)
        }
        return time
    }
    
    private func getSavePathURL() -> NSURL {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let time = Int(NSDate().timeIntervalSince1970)
        let savePath = (documentDirectory as NSString).stringByAppendingPathComponent("mergeVideo-\(time).mov")
        let url = NSURL(fileURLWithPath: savePath)
        return url
    }
    
    private func orientationFromTransform(transform: CGAffineTransform) -> (orientation: UIImageOrientation, isPortrait: Bool) {
        var assetOrientation = UIImageOrientation.Up
        var isPortrait = false
        if transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0 {
            assetOrientation = .Right
            isPortrait = true
        } else if transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0 {
            assetOrientation = .Left
            isPortrait = true
        } else if transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0 {
            assetOrientation = .Up
        } else if transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0 {
            assetOrientation = .Down
        }
        return (assetOrientation, isPortrait)
    }
    
    private func videoCompositionInstructionForTrack(track: AVCompositionTrack,
                                                     asset: AVAsset,
                                                     fixRotate: Bool,
                                                     targetSize: CGSize) -> AVMutableVideoCompositionLayerInstruction {
        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        if fixRotate {
            let assetTrack = asset.tracksWithMediaType(AVMediaTypeVideo)[0]
            let transform = assetTrack.preferredTransform
            let assetInfo = orientationFromTransform(transform)
            
            debugPrint("Asset nature size: \(assetTrack.naturalSize)")
            
            var scaleToFitRatio = targetSize.width / assetTrack.naturalSize.width
            debugPrint("Scale ratio: \(scaleToFitRatio)")
            if assetInfo.isPortrait {
                scaleToFitRatio = targetSize.width / assetTrack.naturalSize.height
                let scaleFactor = CGAffineTransformMakeScale(scaleToFitRatio, scaleToFitRatio)
                instruction.setTransform(CGAffineTransformConcat(assetTrack.preferredTransform, scaleFactor), atTime: kCMTimeZero)
            } else {
                let scaleFactor = CGAffineTransformMakeScale(scaleToFitRatio, scaleToFitRatio)
                if assetInfo.orientation == .Down {
                    var concat = CGAffineTransformConcat(CGAffineTransformConcat(assetTrack.preferredTransform, scaleFactor), CGAffineTransformMakeTranslation(0, targetSize.width / 2))
                    let fixUpsideDown = CGAffineTransformMakeRotation(CGFloat(M_PI))
                    let windowBounds = CGRect(origin: .zero, size: targetSize)
                    let yFix = assetTrack.naturalSize.height + windowBounds.height
                    let centerFix = CGAffineTransformMakeTranslation(assetTrack.naturalSize.width, yFix)
                    concat = CGAffineTransformConcat(CGAffineTransformConcat(fixUpsideDown, centerFix), scaleFactor)
                    instruction.setTransform(concat, atTime: kCMTimeZero)
                } else {
                    instruction.setTransform(scaleFactor, atTime: kCMTimeZero)
                }
            }
            
            debugPrint("Video item scale: \(scaleToFitRatio)")
        }
        
        return instruction
    }
}

// MARK: - Animation

extension MergeVideosViewController {
    func applyVideoEffectsToComposition(composition: AVMutableVideoComposition, size: CGSize, hasAnimations: Bool, hasTextEffects: Bool) {
        
        guard hasAnimations || hasTextEffects else { return }
        
        /// Add animation
        let parentLayer = CALayer()
        parentLayer.contentsScale = UIScreen.mainScreen().scale
        parentLayer.zPosition = 0.0
        parentLayer.frame = CGRectMake(0, 0, size.width, size.height)
        
        let videoLayer = CALayer()
        videoLayer.contentsScale = UIScreen.mainScreen().scale
        videoLayer.zPosition = 0.0
        videoLayer.frame = CGRectMake(0, 0, size.width, size.height)
        
        parentLayer.addSublayer(videoLayer)
        
        applyVideoAnimationsToParentLayer(parentLayer, size: size)
        
        if hasTextEffects {
            applyVideoTextsToParentLayer(parentLayer, size: size)
        }
        
        composition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, inLayer: parentLayer)
    }
    
    func applyVideoAnimationsToParentLayer(parentLayer: CALayer, size: CGSize) {
        let imageSize = CGSize(width: 60, height: 60)
        
        /// Rotate
        let starImage = UIImage(named: "star.png")!
        let overlayLayer1 = CALayer()
        overlayLayer1.contents = starImage.CGImage
        overlayLayer1.frame = CGRect(origin: CGPoint(x: size.width/2, y: size.height/2 + size.height/3), size: imageSize)
        overlayLayer1.masksToBounds = true
        
        let animation1 = CABasicAnimation(keyPath: "transform.rotation")
        animation1.duration = 1.0
        animation1.repeatCount = .infinity
        animation1.autoreverses = true
        animation1.fromValue = 0.0
        animation1.removedOnCompletion = false
        animation1.toValue = 2.0 * M_PI
        animation1.beginTime = AVCoreAnimationBeginTimeAtZero
        overlayLayer1.addAnimation(animation1, forKey: "rotation")
        
        /// Scale
        let lipsImage = UIImage(named: "lips.png")!
        let overlayLayer2 = CALayer()
        overlayLayer2.contents = lipsImage.CGImage
        overlayLayer2.frame = CGRect(origin: CGPoint(x: size.width/2 + size.width/4, y: size.height/2 - size.height/4), size: imageSize)
        overlayLayer2.masksToBounds = true
        
        let animation2 = CABasicAnimation(keyPath: "transform.scale")
        animation2.duration = 1.0
        animation2.repeatCount = .infinity
        animation2.autoreverses = true
        animation2.removedOnCompletion = false
        animation2.fromValue = 1.0
        animation2.toValue = 3.0
        animation2.beginTime = AVCoreAnimationBeginTimeAtZero
        overlayLayer2.addAnimation(animation2, forKey: "scale")
        
        
        /// Fade
        let emojiImage = UIImage(named: "emoji.png")!
        let overlayLayer3 = CALayer()
        overlayLayer3.contents = emojiImage.CGImage
        overlayLayer3.frame = CGRect(origin: CGPoint(x: size.width/2 - size.width/3, y: size.height/2 - size.height/5), size: imageSize)
        overlayLayer3.masksToBounds = true
        
        let animation3 = CABasicAnimation(keyPath: "opacity")
        animation3.duration = 0.5
        animation3.repeatCount = .infinity
        animation3.autoreverses = true
        animation3.removedOnCompletion = false
        animation3.fromValue = 1.0
        animation3.toValue = 0.0
        animation3.beginTime = AVCoreAnimationBeginTimeAtZero
        overlayLayer3.addAnimation(animation3, forKey: "animateOpacity")
        
        
        
        let glassesImage = UIImage(named: "dealwithit")!
        let overlayLayer4 = CALayer()
        overlayLayer4.contents = glassesImage.CGImage
        overlayLayer4.frame = CGRect(x: -1000, y: -1000, width: 350, height: 55)
        overlayLayer4.masksToBounds = true
        
        let animation4_1 = CABasicAnimation(keyPath: "position")
        animation4_1.duration = 0.5
        animation4_1.removedOnCompletion = false
        animation4_1.fromValue = NSValue(CGPoint: CGPoint(x: size.width, y: size.height))
        animation4_1.toValue = NSValue(CGPoint: CGPoint(x: size.width/2 + 20, y: size.height/2 + 10))
        animation4_1.beginTime = 19
        animation4_1.fillMode = kCAFillModeForwards
        overlayLayer4.addAnimation(animation4_1, forKey: "animatePosition1")
        
        let animation4_2 = CABasicAnimation(keyPath: "position")
        animation4_2.duration = 0.5
        animation4_2.removedOnCompletion = false
        animation4_2.fromValue = NSValue(CGPoint: CGPoint(x: size.width/2, y: size.height/2))
        animation4_2.toValue = NSValue(CGPoint: CGPoint(x: -70, y: -70))
        animation4_2.beginTime = 21.5
        animation4_2.fillMode = kCAFillModeForwards
        overlayLayer4.addAnimation(animation4_2, forKey: "animatePosition2")
        
        
        parentLayer.addSublayer(overlayLayer1)
        parentLayer.addSublayer(overlayLayer2)
        parentLayer.addSublayer(overlayLayer3)
        parentLayer.addSublayer(overlayLayer4)
    }
    
    func applyVideoTextsToParentLayer(parentLayer: CALayer, size: CGSize) {
        let font = UIFont(name: "ITC Avant Garde Gothic Std", size: 100)!
        
        /// Tien
        let textLayer1 = CATextLayer()
        debugPrint("Screen scale: \(UIScreen.mainScreen().scale)")
        
        textLayer1.font = font
        textLayer1.fontSize = 41
        textLayer1.string = "MR. TIEN"
        textLayer1.frame = CGRect(x: 20, y: 100, width: size.width, height: 41)
        textLayer1.alignmentMode = kCAAlignmentCenter
        textLayer1.foregroundColor = UIColor.redColor().CGColor
        
        let animation1 = CABasicAnimation(keyPath: "opacity")
        animation1.duration = 0
        animation1.removedOnCompletion = false
        animation1.fromValue = 1.0
        animation1.toValue = 0.0
        animation1.beginTime = 7.5
        animation1.fillMode = kCAFillModeBoth
        textLayer1.addAnimation(animation1, forKey: "animateOpacity")
        
        
        let animation1_1 = CASpringAnimation(keyPath: "position.x")
        animation1_1.damping = 5
        animation1_1.beginTime = 2
        animation1_1.removedOnCompletion = false
        animation1_1.fromValue = textLayer1.position.x
        animation1_1.toValue = textLayer1.position.x + 70
        animation1_1.duration = animation1_1.settlingDuration
        textLayer1.addAnimation(animation1_1, forKey: "animateDamping")
        
        parentLayer.addSublayer(textLayer1)
        
        
        /// Sunny
        let textLayer2 = CATextLayer()
        textLayer2.font = font
        textLayer2.frame = CGRect(x: -1000, y: -1000, width: size.width, height: 100)
        textLayer2.string = "MR. SUNNY"
        textLayer2.alignmentMode = kCAAlignmentCenter
        textLayer2.foregroundColor = UIColor.greenColor().CGColor
        
        let animation2_1 = CABasicAnimation(keyPath: "position")
        animation2_1.duration = 0
        animation2_1.removedOnCompletion = false
        animation2_1.fromValue = NSValue(CGPoint: CGPoint(x: size.width - 120, y: size.height - 150))
        animation2_1.toValue = NSValue(CGPoint: CGPoint(x: size.width - 120, y: size.height - 150))
        animation2_1.beginTime = 7.5
        animation2_1.fillMode = kCAFillModeForwards
        textLayer2.addAnimation(animation2_1, forKey: "animatePosition1")
        
        let animation2_2 = CABasicAnimation(keyPath: "position")
        animation2_2.duration = 1.0
        animation2_2.removedOnCompletion = false
        animation2_2.fromValue = NSValue(CGPoint: CGPoint(x: size.width - 120, y: size.height - 150))
        animation2_2.toValue = NSValue(CGPoint: CGPoint(x: size.width + size.width, y: 20))
        animation2_2.beginTime = 11
        animation2_2.fillMode = kCAFillModeForwards
        textLayer2.addAnimation(animation2_2, forKey: "animatePosition2")
        
        
        /// tam
        let textLayer3 = CATextLayer()
        textLayer3.font = font
        textLayer3.frame = CGRect(x: -1000, y: -1000, width: size.width, height: 100)
        textLayer3.string = "tam"
        textLayer3.alignmentMode = kCAAlignmentCenter
        textLayer3.foregroundColor = UIColor.grayColor().CGColor
        textLayer3.needsDisplay()
        
        let animation3_1 = CABasicAnimation(keyPath: "position")
        animation3_1.duration = 0
        animation3_1.removedOnCompletion = false
        animation3_1.fromValue = NSValue(CGPoint: CGPoint(x: size.width/2, y: size.height/2))
        animation3_1.toValue = NSValue(CGPoint: CGPoint(x: size.width/2, y: size.height/2))
        animation3_1.beginTime = 13
        animation3_1.fillMode = kCAFillModeForwards
        textLayer3.addAnimation(animation3_1, forKey: "animatePosition1")
        
        
        let animation3_2 = CABasicAnimation(keyPath: "position")
        animation3_2.duration = 1
        animation3_2.removedOnCompletion = false
        animation3_2.fromValue = NSValue(CGPoint: CGPoint(x: size.width/2, y: size.height/2))
        animation3_2.toValue = NSValue(CGPoint: CGPoint(x: -50, y: -50))
        animation3_2.beginTime = 17
        animation3_2.fillMode = kCAFillModeForwards
        textLayer3.addAnimation(animation3_2, forKey: "animatePosition2")
        
        
        
        
        /// Tai
        let textLayer4 = CATextLayer()
        textLayer4.font = font
        textLayer4.frame = CGRect(x: -1000, y: -1000, width: size.width, height: 100)
        textLayer4.string = "THUG LIFE!!!"
        textLayer4.alignmentMode = kCAAlignmentCenter
        textLayer4.foregroundColor = UIColor.orangeColor().CGColor
        textLayer4.needsDisplay()
        
        let animation4_1 = CABasicAnimation(keyPath: "position")
        animation4_1.duration = 1
        animation4_1.removedOnCompletion = false
        animation4_1.fromValue = NSValue(CGPoint: CGPoint(x: size.width/2, y: -70))
        animation4_1.toValue = NSValue(CGPoint: CGPoint(x: size.width/2, y: 30))
        animation4_1.beginTime = 18
        animation4_1.fillMode = kCAFillModeForwards
        textLayer4.addAnimation(animation4_1, forKey: "animatePosition1")
        
        
        let animation4_2 = CABasicAnimation(keyPath: "position")
        animation4_2.duration = 0.5
        animation4_2.removedOnCompletion = false
        animation4_2.fromValue = NSValue(CGPoint: CGPoint(x: size.width/2, y: 30))
        animation4_2.toValue = NSValue(CGPoint: CGPoint(x: size.width + size.width, y: 30))
        animation4_2.beginTime = 21
        animation4_2.fillMode = kCAFillModeForwards
        textLayer4.addAnimation(animation4_2, forKey: "animatePosition2")
        
        
        
        
        /// Cuong
        let textLayer5 = CATextLayer()
        textLayer5.font = font
        textLayer5.frame = CGRect(x: -1000, y: -1000, width: size.width, height: 100)
        textLayer5.string = "MR. CUONG"
        textLayer5.alignmentMode = kCAAlignmentCenter
        textLayer5.foregroundColor = UIColor.orangeColor().CGColor
        textLayer5.needsDisplay()
        
        let animation5_1 = CABasicAnimation(keyPath: "position")
        animation5_1.duration = 1
        animation5_1.removedOnCompletion = false
        animation5_1.fromValue = NSValue(CGPoint: CGPoint(x: 120, y: -size.height))
        animation5_1.toValue = NSValue(CGPoint: CGPoint(x: 120, y: 2*size.height/3))
        animation5_1.beginTime = 22
        animation5_1.fillMode = kCAFillModeForwards
        textLayer5.addAnimation(animation5_1, forKey: "animatePosition1")
        
        
        let animation5_2 = CABasicAnimation(keyPath: "position")
        animation5_2.duration = 0.5
        animation5_2.removedOnCompletion = false
        animation5_2.fromValue = NSValue(CGPoint: CGPoint(x: 100, y: 2*size.height/3))
        animation5_2.toValue = NSValue(CGPoint: CGPoint(x: size.width * 2, y: size.height/3 * 2))
        animation5_2.beginTime = 26
        animation5_2.fillMode = kCAFillModeForwards
        textLayer5.addAnimation(animation5_2, forKey: "animatePosition2")
        
        parentLayer.addSublayer(textLayer1)
        parentLayer.addSublayer(textLayer2)
        parentLayer.addSublayer(textLayer3)
        parentLayer.addSublayer(textLayer4)
        parentLayer.addSublayer(textLayer5)
        
        parentLayer.shouldRasterize = true
    }
}
