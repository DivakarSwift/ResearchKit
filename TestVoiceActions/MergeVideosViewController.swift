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
    
    var blankAudioAsset: AVAsset!
    var applauseAudioAsset: AVAsset!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        
        ////////////////////////////////////////////////
        ////////////////////////////////////////////////
        let mixComposition = AVMutableComposition()
        var atTime: CMTime = kCMTimeZero
        
        ////////////////////////////////////////////////
        //////////////// Add Sence ////////////////////
        ///////////////////////////////////////////////
        
        let parentLayer = CALayer()
        parentLayer.frame = CGRectMake(0, 0, ExportedVideoSize.width, ExportedVideoSize.height)
        
        let backgroundLayer = CALayer()
        backgroundLayer.backgroundColor = UIColor.whiteColor().CGColor
        backgroundLayer.frame = CGRect(origin: .zero, size: ExportedVideoSize)
        
        parentLayer.addSublayer(backgroundLayer)
        
        
        let videoLayer = CALayer()
        videoLayer.backgroundColor = UIColor.whiteColor().CGColor
        videoLayer.frame = CGRect(origin: .zero, size: ExportedVideoSize)
        parentLayer.addSublayer(videoLayer)
        
        var instructions: [AVMutableVideoCompositionInstruction] = []
        let (introInstruction, introEndTime) = addIntroScenceAtTime(atTime,
                                                                    parentLayer: parentLayer,
                                                                    composition: mixComposition,
                                                                    videoItemSize: videoItemSize)
        
        atTime = introEndTime
        instructions.append(introInstruction)
        ////////////////////////////////////////////////
        
        
        ////////////////////////////////////////////////
        for (index, asset) in assets.enumerate() {
            var title: String = ""
            switch index {
            case 0:
                title = "Tien"
            case 1:
                title = "Sunny"
            case 2:
                title = "Tam"
            case 3:
                title = "Tai"
            case 4:
                title = "Cuong"
            default:
                title = ""
            }
            let (instruction, endTime) = addVideoItemScenceAtTime(atTime,
                                                                  parentLayer: parentLayer,
                                                                  composition: mixComposition,
                                                                  videoAsset: asset,
                                                                  title: title,
                                                                  videoItemSize: videoItemSize,
                                                                  videoItemIndex: index)
            atTime = endTime
            instructions.append(instruction)
        }
        ////////////////////////////////////////////////
        
        
        
        
        ////////////////////////////////////////////////
        let (sumaryInstruction, sumaryEndTime) = addSumaryScenceAtTime(atTime,
                                                                       parentLayer: parentLayer,
                                                                       composition: mixComposition,
                                                                       videoItemSize: videoItemSize)
        atTime = sumaryEndTime
        instructions.append(sumaryInstruction)
        ////////////////////////////////////////////////
        
        
        
        ////////////////////////////////////////////////
        ////////////////////////////////////////////////
        let renderSize = ExportedVideoSize
        let mainComposition = AVMutableVideoComposition(propertiesOfAsset: mixComposition)
        mainComposition.instructions = instructions
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
    
    private func blankInstructionAtTimeRange(timeRange: CMTimeRange,
                                             composition: AVMutableComposition,
                                             videoSize: CGSize) -> AVMutableVideoCompositionLayerInstruction {
        let blankTrack = composition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        try! blankTrack.insertTimeRange(timeRange, ofTrack: blankVideoAsset.tracksWithMediaType(AVMediaTypeVideo)[0], atTime: timeRange.start)
        let layerInstruction = videoCompositionInstructionForTrack(blankTrack,
                                                                   asset: blankVideoAsset,
                                                                   fixRotate: true,
                                                                   frame: CGRect(origin: .zero, size: videoSize))
        layerInstruction.setOpacity(0.0, atTime: CMTimeAdd(timeRange.start, timeRange.duration))
        
        
        return layerInstruction
    }
    
    private func addBlankAudioInstructionAtTimeRange(timeRange: CMTimeRange,
                                             composition: AVMutableComposition) {
        let blankAudioTrack = composition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        try! blankAudioTrack.insertTimeRange(timeRange, ofTrack: blankAudioAsset.tracksWithMediaType(AVMediaTypeAudio)[0], atTime: timeRange.start)
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
                           fromPoint: CGPoint,
                           toPoint: CGPoint,
                           damping: Bool = false) {
        let beginTime = beginTime == 0.0 ? AVCoreAnimationBeginTimeAtZero : beginTime
        
        if damping {
            let hideAnimation = CASpringAnimation(keyPath: "position")
            hideAnimation.damping = 10.0
            hideAnimation.initialVelocity = 0.7
            hideAnimation.beginTime = beginTime
            hideAnimation.removedOnCompletion = false
            hideAnimation.fromValue = NSValue(CGPoint: fromPoint)
            hideAnimation.toValue = NSValue(CGPoint: toPoint)
            hideAnimation.duration = hideAnimation.settlingDuration
            hideAnimation.fillMode = kCAFillModeForwards
            layer.addAnimation(hideAnimation, forKey: "animatePosition\(NSDate().timeIntervalSince1970)")
        } else {
            let hideAnimation = CABasicAnimation(keyPath: "position")
            hideAnimation.duration = duration
            hideAnimation.removedOnCompletion = false
            hideAnimation.fromValue = NSValue(CGPoint: fromPoint)
            hideAnimation.toValue = NSValue(CGPoint: toPoint)
            hideAnimation.beginTime = beginTime
            hideAnimation.fillMode = kCAFillModeForwards
            layer.addAnimation(hideAnimation, forKey: "animatePosition\(NSDate().timeIntervalSince1970)")
        }
    }
    
    private func zoomOutLayer(layer: CALayer,
                             duaration: CFTimeInterval,
                             beginTime: CFTimeInterval,
                             damping: Bool) {
        let scaleAnimation: CABasicAnimation!
        if damping {
            scaleAnimation = CASpringAnimation(keyPath: "transform.scale")
            scaleAnimation.duration = (scaleAnimation as! CASpringAnimation).settlingDuration
            (scaleAnimation as! CASpringAnimation).damping = 10.0
            (scaleAnimation as! CASpringAnimation).initialVelocity = 0.7
        } else {
            scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
            scaleAnimation.duration = duaration
        }
        scaleAnimation.removedOnCompletion = false
        scaleAnimation.fromValue = 0.0
        scaleAnimation.toValue = 1.0
        scaleAnimation.beginTime = beginTime
        scaleAnimation.fillMode = kCAFillModeForwards
        layer.addAnimation(scaleAnimation, forKey: "scaleAnimate\(NSDate().timeIntervalSince1970)")
    }
    
    private func imageLayer(imageName: String) -> CALayer {
        let image = UIImage(named: imageName)!
        return imageLayer(image)
    }
    
    private func imageLayer(image: UIImage) -> CALayer {
        let layer = CALayer()
        layer.contents = image.CGImage
        layer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: image.size)
        layer.masksToBounds = true
        layer.contentsGravity = kCAGravityResizeAspect
        return layer
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
    
    
    private func addCenterTextSenceAtTime(inout atTime: CMTime,
                                                size: CGSize,
                                                parentLayer: CALayer,
                                                backgroundColor: UIColor,
                                                textColor: UIColor,
                                                text: String,
                                                textFont: UIFont,
                                                textFontSize: CGFloat,
                                                hideWhenEnd: Bool = true,
                                                duration: Int64) -> (backgroundLayer: CALayer, textLayer: CATextLayer) {
        
        let result = blankCenterTextLayer(backgroundColor: backgroundColor,
                                          frame: parentLayer.bounds,
                                          text: text,
                                          textColor: textColor,
                                          textFont: textFont,
                                          textFontSize: textFontSize)
        parentLayer.addSublayer(result.layer)
        if atTime.seconds != 0.0 {
            result.layer.opacity = 0.0
            self.hideLayer(result.layer, hidden: false, duration: 0, beginTime: atTime.seconds)
        }
        
        atTime = CMTimeAdd(atTime, CMTimeMake(duration, kCMTimeZero.timescale))
        
        if hideWhenEnd {
            self.hideLayer(result.layer, hidden: true, duration: 0, beginTime: atTime.seconds)
        }
        return (result.layer, result.textLayer)
    }
    
    
    private func layerWithBGColor(bgColor: UIColor,
                                  frame: CGRect,
                                  showTime: CFTimeInterval) -> CALayer {
        let layer = CALayer()
        layer.backgroundColor = bgColor.CGColor
        layer.frame = frame
        if showTime != 0.0 {
            layer.opacity = 0.0
            hideLayer(layer,
                      hidden: false,
                      duration: 0,
                      beginTime: showTime)
        }
        return layer
    }
    
    
    private func emitterCellFromImageName(imageName: String) -> CAEmitterCell {
        let fireworkCell = CAEmitterCell()
        fireworkCell.contents = UIImage(named: imageName)!.CGImage
        fireworkCell.birthRate = 21
        fireworkCell.scale = 0.6
        fireworkCell.velocity = 130
        fireworkCell.lifetime = 100
        fireworkCell.alphaSpeed = -0.2
        fireworkCell.yAcceleration = -80
        fireworkCell.beginTime = 1.5
        fireworkCell.duration = 0.1
        fireworkCell.emissionRange = 2 * CGFloat(M_PI)
        fireworkCell.scaleSpeed = -0.1
        fireworkCell.spin = 2
        return fireworkCell
    }
    
}


// MARK: - Hard code

extension MergeVideosViewController {
    private func addSumaryScenceAtTime(startTime: CMTime,
                                       parentLayer: CALayer,
                                       composition: AVMutableComposition,
                                       videoItemSize: CGSize) -> (AVMutableVideoCompositionInstruction, endTime: CMTime) {
        let backgroundColor = UIColor(red: 102/255, green: 89/255, blue: 255/255, alpha: 1).CGColor
        var atTime = startTime
        let animationDuration = 0.25
        let spaceWidth = videoItemSize.width/3
        let cuongThumbnailLayer = imageLayer(assets[4].previewImageAtTime()!.resizeImage(newHeight: videoItemSize.height))
        cuongThumbnailLayer.anchorPoint = .zero
        cuongThumbnailLayer.position = CGPoint(x: parentLayer.bounds.width, y: 0)
        cuongThumbnailLayer.opacity = 0.0
        parentLayer.addSublayer(cuongThumbnailLayer)
        
        hideLayer(cuongThumbnailLayer,
                  hidden: false,
                  duration: 0,
                  beginTime: atTime.seconds)
        moveLayer(cuongThumbnailLayer,
                  duration: animationDuration,
                  beginTime: atTime.seconds,
                  fromPoint: cuongThumbnailLayer.position,
                  toPoint: .zero)
        
        
        
        let taiThumbnailLayer = imageLayer(assets[3].previewImageAtTime()!.resizeImage(newHeight: videoItemSize.height))
        taiThumbnailLayer.anchorPoint = .zero
        taiThumbnailLayer.position = CGPoint(x: parentLayer.bounds.width, y: 0)
        taiThumbnailLayer.opacity = 0.0
        parentLayer.addSublayer(taiThumbnailLayer)
        
        hideLayer(taiThumbnailLayer,
                  hidden: false,
                  duration: 0,
                  beginTime: atTime.seconds)
        moveLayer(taiThumbnailLayer,
                  duration: animationDuration,
                  beginTime: atTime.seconds + animationDuration,
                  fromPoint: taiThumbnailLayer.position,
                  toPoint: CGPoint(x: spaceWidth, y: 0))
        
        
        
        
        let tamThumbnailLayer = imageLayer(assets[2].previewImageAtTime()!.resizeImage(newHeight: videoItemSize.height))
        tamThumbnailLayer.anchorPoint = .zero
        tamThumbnailLayer.position = CGPoint(x: parentLayer.bounds.width, y: 0)
        tamThumbnailLayer.opacity = 0.0
        parentLayer.addSublayer(tamThumbnailLayer)
        
        hideLayer(tamThumbnailLayer,
                  hidden: false,
                  duration: 0,
                  beginTime: atTime.seconds)
        moveLayer(tamThumbnailLayer,
                  duration: animationDuration,
                  beginTime: atTime.seconds + animationDuration * 2,
                  fromPoint: tamThumbnailLayer.position,
                  toPoint: CGPoint(x: 2*spaceWidth, y: 0))
        
        
        let sunnyThumbnailLayer = imageLayer(assets[1].previewImageAtTime()!.resizeImage(newHeight: videoItemSize.height))
        sunnyThumbnailLayer.anchorPoint = .zero
        sunnyThumbnailLayer.position = CGPoint(x: parentLayer.bounds.width, y: 0)
        sunnyThumbnailLayer.opacity = 0.0
        parentLayer.addSublayer(sunnyThumbnailLayer)
        
        hideLayer(sunnyThumbnailLayer,
                  hidden: false,
                  duration: 0,
                  beginTime: atTime.seconds)
        moveLayer(sunnyThumbnailLayer,
                  duration: animationDuration,
                  beginTime: atTime.seconds + animationDuration * 3,
                  fromPoint: sunnyThumbnailLayer.position,
                  toPoint: CGPoint(x: 3*spaceWidth, y: 0))
        
        
        let tienThumbnailLayer = imageLayer(assets[0].previewImageAtTime()!.resizeImage(newHeight: videoItemSize.height))
        tienThumbnailLayer.anchorPoint = .zero
        tienThumbnailLayer.position = CGPoint(x: parentLayer.bounds.width, y: 0)
        tienThumbnailLayer.opacity = 0.0
        parentLayer.addSublayer(tienThumbnailLayer)
        
        let lastEndPoint = CGPoint(x: 4*spaceWidth, y: 0)
        hideLayer(tienThumbnailLayer,
                  hidden: false,
                  duration: 0,
                  beginTime: atTime.seconds)
        moveLayer(tienThumbnailLayer,
                  duration: animationDuration,
                  beginTime: atTime.seconds + animationDuration * 4,
                  fromPoint: tienThumbnailLayer.position,
                  toPoint: lastEndPoint)
        
        
        let whoNextLayer = layerWithBGColor(UIColor(red: 228/255, green: 63/255, blue: 107/255, alpha: 1),
                                            frame: CGRect(x: 0, y: 0, width: (parentLayer.bounds.width - lastEndPoint.x - tienThumbnailLayer.bounds.width/2), height: parentLayer.bounds.height),
                                            showTime: atTime.seconds)
        whoNextLayer.anchorPoint = .zero
        whoNextLayer.position = CGPoint(x: parentLayer.bounds.width,
                                        y: 0)
        parentLayer.addSublayer(whoNextLayer)
        
        
        let whoNextTextLayer = CATextLayer()
        whoNextTextLayer.string = "WHO\nNEXT?"
        whoNextTextLayer.wrapped = true
        whoNextTextLayer.font = font1
        whoNextTextLayer.fontSize = 70
        whoNextTextLayer.frame = CGRect(origin: .zero, size: CGSize(width: whoNextLayer.bounds.width,
            height: 200))
        whoNextTextLayer.position = CGPoint(x: whoNextLayer.bounds.width/2, y: whoNextLayer.bounds.height/2)
        whoNextTextLayer.alignmentMode = kCAAlignmentCenter
        whoNextLayer.addSublayer(whoNextTextLayer)
        
        
        moveLayer(whoNextLayer,
                  duration: animationDuration,
                  beginTime: atTime.seconds + animationDuration * 5,
                  fromPoint: whoNextLayer.position,
                  toPoint: CGPoint(x: parentLayer.bounds.width - whoNextLayer.bounds.width,
                    y: 0),
                  damping: true)
        
        atTime = CMTimeAdd(atTime, CMTimeMake(4, kCMTimeZero.timescale))
        
        let letJoinLayer = layerWithBGColor(UIColor.whiteColor(),
                                            frame: CGRect(origin: CGPoint(x: 0, y: -parentLayer.bounds.height),
                                                size: parentLayer.bounds.size),
                                            showTime: atTime.seconds)
        parentLayer.addSublayer(letJoinLayer)
        moveLayer(letJoinLayer,
                  duration: 0.35,
                  beginTime: atTime.seconds,
                  fromPoint: letJoinLayer.position,
                  toPoint: CGPoint(x: parentLayer.bounds.width/2, y: parentLayer.bounds.height/2))
        
        
        let letJoinTextLayer = CATextLayer()
        letJoinTextLayer.string = "Let join with us at:"
        letJoinTextLayer.font = font1
        letJoinTextLayer.fontSize = 50
        letJoinTextLayer.frame = CGRect(x: 0,
                                        y: letJoinLayer.bounds.height/2 + letJoinTextLayer.fontSize,
                                        width: letJoinLayer.bounds.width,
                                        height: letJoinTextLayer.fontSize + 10)
        letJoinTextLayer.foregroundColor = UIColor(red: 107/255, green: 97/255, blue: 255/255, alpha: 1).CGColor
        letJoinTextLayer.alignmentMode = kCAAlignmentCenter
        letJoinLayer.addSublayer(letJoinTextLayer)
        
        let letJoinAddressLayer = CATextLayer()
        letJoinAddressLayer.string = "http://hilao.co"
        letJoinAddressLayer.font = font1
        letJoinAddressLayer.fontSize = 100
        letJoinAddressLayer.frame = CGRect(x: 0,
                                        y: letJoinLayer.bounds.height/2 - letJoinTextLayer.fontSize - 50,
                                        width: letJoinLayer.bounds.width,
                                        height: letJoinTextLayer.fontSize + 70)
        letJoinAddressLayer.foregroundColor = UIColor(red: 84/255, green: 212/255, blue: 221/255, alpha: 1).CGColor
        letJoinAddressLayer.alignmentMode = kCAAlignmentCenter
        letJoinLayer.addSublayer(letJoinAddressLayer)
        
        zoomOutLayer(letJoinAddressLayer,
                     duaration: 0.5,
                     beginTime: atTime.seconds,
                     damping: true)
        
        atTime = CMTimeAdd(atTime, CMTimeMake(5, kCMTimeZero.timescale))
        
        
        
        
        /// Instruction
        let duration = CMTimeSubtract(atTime, startTime)
        let timeRange = CMTimeRangeMake(startTime, duration)
        let layerInstruction = blankInstructionAtTimeRange(timeRange,
                                                           composition: composition,
                                                           videoSize: ExportedVideoSize)
        
        addBlankAudioInstructionAtTimeRange(timeRange,
                                            composition: composition)
        
        let introInstruction = AVMutableVideoCompositionInstruction()
        introInstruction.timeRange = timeRange
        introInstruction.backgroundColor = backgroundColor
        introInstruction.layerInstructions = [layerInstruction]
        
        return (introInstruction, atTime)
    }
    
    private func addVideoItemScenceAtTime(startTime: CMTime,
                                          parentLayer: CALayer,
                                          composition: AVMutableComposition,
                                          videoAsset: AVAsset,
                                          title: String,
                                          videoItemSize: CGSize,
                                          videoItemIndex: Int) -> (AVMutableVideoCompositionInstruction, endTime: CMTime) {
        var videoAssetDuration = videoAsset.duration
        let randomSide = arc4random_uniform(2) == 0
        let startPoint = randomSide ? CGPoint(x: -parentLayer.bounds.width/2, y: parentLayer.bounds.height/2) : CGPoint(x: parentLayer.bounds.width*3/2, y: parentLayer.bounds.height/2)
        let endPoint = randomSide ? CGPoint(x: (parentLayer.bounds.width/2 - videoItemSize.width) - 40,
                                            y: startPoint.y) : CGPoint(x: (parentLayer.bounds.width/2 + videoItemSize.width) + 40, y: startPoint.y)
        
        let atTime = startTime
        let backgroundColor = UIColor(red: 102/255, green: 89/255, blue: 255/255, alpha: 1).CGColor
        
        let tienTitleTextLayer = CATextLayer()
        tienTitleTextLayer.string = title
        tienTitleTextLayer.font = font1
        tienTitleTextLayer.fontSize = 40
        tienTitleTextLayer.foregroundColor = UIColor(red: 232/255, green: 212/255, blue: 65/255, alpha: 1).CGColor
        tienTitleTextLayer.alignmentMode = randomSide ? kCAAlignmentRight : kCAAlignmentLeft
        tienTitleTextLayer.frame = CGRect(origin: .zero,
                                          size: CGSize(width: parentLayer.bounds.width/2 - videoItemSize.width/2, height: 50))
        tienTitleTextLayer.position = startPoint
        tienTitleTextLayer.opacity = 0.0
        parentLayer.addSublayer(tienTitleTextLayer)
        
        hideLayer(tienTitleTextLayer,
                  hidden: false,
                  duration: 0,
                  beginTime: atTime.seconds + 0.5)
        
        
        moveLayer(tienTitleTextLayer,
                  duration: 0.35,
                  beginTime: atTime.seconds + 1.0,
                  fromPoint: tienTitleTextLayer.position,
                  toPoint: endPoint,
                  damping: true)
        
        moveLayer(tienTitleTextLayer,
                  duration: 0.35,
                  beginTime: atTime.seconds + videoAssetDuration.seconds - 1.0,
                  fromPoint: tienTitleTextLayer.position,
                  toPoint: startPoint)
        
        hideLayer(tienTitleTextLayer,
                  hidden: true,
                  duration: 0,
                  beginTime: atTime.seconds + videoAssetDuration.seconds + 2)
        
        
        if videoItemIndex == 0 {
            var beginTime = CMTimeAdd(startTime, videoAssetDuration)
            
            let image = videoAsset.previewImageAtTime(videoAsset.duration)
            let firstImageLayer = imageLayer(image!.resizeImage(newHeight: videoItemSize.height))
            firstImageLayer.position = CGPoint(x: parentLayer.bounds.width/2, y: parentLayer.bounds.height/2)
            firstImageLayer.opacity = 0.0
            parentLayer.addSublayer(firstImageLayer)
            
            hideLayer(firstImageLayer,
                      hidden: false,
                      duration: 0,
                      beginTime: beginTime.seconds)
            
            let cupImageLayer = imageLayer("cup.png")
            let cupHeight = CGFloat(100)
            cupImageLayer.frame = CGRect(x: parentLayer.bounds.width/2 - cupHeight/2,
                                         y: -cupHeight,
                                         width: cupHeight,
                                         height: cupHeight)
            cupImageLayer.opacity = 0.0
            parentLayer.addSublayer(cupImageLayer)
            hideLayer(cupImageLayer,
                      hidden: false,
                      duration: 0,
                      beginTime: beginTime.seconds)
            moveLayer(cupImageLayer,
                      duration: 0.5,
                      beginTime: beginTime.seconds,
                      fromPoint: cupImageLayer.position,
                      toPoint: CGPoint(x: cupImageLayer.position.x, y: cupHeight),
                      damping: true)
            
            
            let emitterLayer = CAEmitterLayer()
            emitterLayer.opacity = 0.0
            emitterLayer.frame = parentLayer.bounds
            
            hideLayer(emitterLayer,
                      hidden: false,
                      duration: 0,
                      beginTime: beginTime.seconds)
            
            let emitterCell = CAEmitterCell()
            emitterCell.emissionLongitude = CGFloat(M_PI_4)
            emitterCell.emissionLatitude = 0
            emitterCell.lifetime = 2.6
            emitterCell.birthRate = 6
            emitterCell.velocity = 300
            emitterCell.velocityRange = 100
            emitterCell.yAcceleration = 150
            emitterCell.emissionRange = CGFloat(M_PI_4)
            let newColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1).CGColor
            emitterCell.color = newColor
            
            emitterCell.redRange = 0.9
            emitterCell.greenRange = 0.9
            emitterCell.blueRange = 0.9
            emitterCell.name = "base"
            
            let fireworkRedCell = emitterCellFromImageName("red.png")
            let fireworkGreenCell = emitterCellFromImageName("green.png")
            let fireworkYellowCell = emitterCellFromImageName("yellow.png")
            
            emitterCell.emitterCells = [fireworkRedCell, fireworkGreenCell, fireworkYellowCell]
            emitterLayer.emitterCells = [emitterCell]
            parentLayer.addSublayer(emitterLayer)
            
            //////
            let cheerDuration = CMTimeMake(3, kCMTimeZero.timescale)
            videoAssetDuration = CMTimeAdd(videoAssetDuration, cheerDuration)
            
            //Add applause
            let applauseAudioTrack = composition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
            try! applauseAudioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, cheerDuration), ofTrack: applauseAudioAsset.tracksWithMediaType(AVMediaTypeAudio)[0], atTime: beginTime)
            
            beginTime = CMTimeAdd(startTime, videoAssetDuration)
            
            hideLayer(firstImageLayer,
                      hidden: true,
                      duration: 0,
                      beginTime: beginTime.seconds)
            
            
            hideLayer(emitterLayer,
                      hidden: true,
                      duration: 0,
                      beginTime: beginTime.seconds)
            
            moveLayer(cupImageLayer,
                      duration: 0.35,
                      beginTime: beginTime.seconds,
                      fromPoint: cupImageLayer.position,
                      toPoint: CGPoint(x: cupImageLayer.position.x, y: -cupHeight))
            
            hideLayer(cupImageLayer,
                      hidden: true,
                      duration: 0.35,
                      beginTime: beginTime.seconds + 1)
        }
        
        //// Instruction
        let assetTimeRange = CMTimeRangeMake(kCMTimeZero, videoAssetDuration)
        let videoTrack = composition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        try! videoTrack.insertTimeRange(assetTimeRange, ofTrack: videoAsset.tracksWithMediaType(AVMediaTypeVideo)[0], atTime: atTime)
        let layerInstruction = videoCompositionInstructionForTrack(videoTrack,
                                                                   asset: videoAsset,
                                                                   fixRotate: true,
                                                                   frame: CGRect(origin: CGPoint(x: ExportedVideoSize.width/2 - videoItemSize.width/2, y: 0),
                                                                    size: videoItemSize))
        
        let audioTrack = composition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        try! audioTrack.insertTimeRange(assetTimeRange, ofTrack: videoAsset.tracksWithMediaType(AVMediaTypeAudio)[0], atTime: atTime)
        
        let tienInstruction = AVMutableVideoCompositionInstruction()
        tienInstruction.timeRange = CMTimeRangeMake(atTime, videoAssetDuration)
        tienInstruction.backgroundColor = backgroundColor
        tienInstruction.layerInstructions = [layerInstruction]
        
        
        let endTime = CMTimeAdd(startTime, videoAssetDuration)
        
        return (tienInstruction, endTime)
        
    }
    
    private func addIntroScenceAtTime(startTime: CMTime,
                                      parentLayer: CALayer,
                                      composition: AVMutableComposition,
                                      videoItemSize: CGSize) -> (instruction: AVMutableVideoCompositionInstruction, endTime: CMTime) {
        var atTime = startTime
        let textFontSize1: CGFloat = 60
        ////////////////////////////////////////////////
        addCenterTextSenceAtTime(&atTime,
                                 size: videoItemSize,
                                 parentLayer: parentLayer,
                                 backgroundColor: UIColor(red: 228/255, green: 63/255, blue: 107/255, alpha: 1),
                                 textColor: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1),
                                 text: "smile.",
                                 textFont: font1,
                                 textFontSize: textFontSize1,
                                 duration: 1)
        ////////////////////////////////////////////////
        
        ////////////////////////////////////////////////
        addCenterTextSenceAtTime(&atTime,
                                 size: videoItemSize,
                                 parentLayer: parentLayer,
                                 backgroundColor: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1),
                                 textColor: UIColor(red: 110/255, green: 96/255, blue: 255/255, alpha: 1),
                                 text: "cry.",
                                 textFont: font1,
                                 textFontSize: textFontSize1,
                                 duration: 1)
        ////////////////////////////////////////////////
        
        
        
        ////////////////////////////////////////////////
        addCenterTextSenceAtTime(&atTime,
                                 size: videoItemSize,
                                 parentLayer: parentLayer,
                                 backgroundColor: UIColor(red: 90/255, green: 214/255, blue: 219/255, alpha: 1),
                                 textColor: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1),
                                 text: "surprise.",
                                 textFont: font1,
                                 textFontSize: textFontSize1,
                                 duration: 1)
        ////////////////////////////////////////////////
        
        
        
        ////////////////////////////////////////////////
        addCenterTextSenceAtTime(&atTime,
                                 size: videoItemSize,
                                 parentLayer: parentLayer,
                                 backgroundColor: UIColor(red: 237/255, green: 207/255, blue: 61/255, alpha: 1),
                                 textColor: UIColor(red: 255/255, green: 66/255, blue: 102/255, alpha: 1),
                                 text: "excited.",
                                 textFont: font1,
                                 textFontSize: textFontSize1,
                                 duration: 1)
        ////////////////////////////////////////////////
        
        
        
        ////////////////////////////////////////////////
        addCenterTextSenceAtTime(&atTime,
                                 size: videoItemSize,
                                 parentLayer: parentLayer,
                                 backgroundColor: UIColor(red: 228/255, green: 63/255, blue: 107/255, alpha: 1),
                                 textColor: UIColor(red: 240/255, green: 206/255, blue: 65/255, alpha: 1),
                                 text: "hectic.",
                                 textFont: font1,
                                 textFontSize: textFontSize1,
                                 duration: 1)
        ////////////////////////////////////////////////
        
        
        
        
        ////////////////////////////////////////////////
        let (allAreLayer, allAreTextLayer) = addCenterTextSenceAtTime(&atTime,
                                                                      size: videoItemSize,
                                                                      parentLayer: parentLayer,
                                                                      backgroundColor: UIColor(red: 102/255, green: 98/255, blue: 255/255, alpha: 1),
                                                                      textColor: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1),
                                                                      text: "all are",
                                                                      textFont: font1,
                                                                      textFontSize: textFontSize1,
                                                                      hideWhenEnd: false,
                                                                      duration: 1)
        addReactionsAndWithAtTime(&atTime,
                                  parentLayer: parentLayer,
                                  allAreLayer: allAreLayer,
                                  allAreTextLayer: allAreTextLayer,
                                  textFontSize: textFontSize1)
        ////////////////////////////////////////////////
        
        
        
        
        ////////////////////////////////////////////////
        let promptLayer = addPromptSceneAtTime(&atTime,
                                               parentLayer: parentLayer,
                                               allAreLayer: allAreLayer,
                                               videoSize: videoItemSize)
        hideLayer(promptLayer,
                  hidden: true,
                  duration: 0,
                  beginTime: atTime.seconds)
        ////////////////////////////////////////////////
        
        
        
        /// Instruction
        let timeRange = CMTimeRangeMake(kCMTimeZero, atTime)
        let layerInstruction = blankInstructionAtTimeRange(timeRange,
                                                           composition: composition,
                                                           videoSize: ExportedVideoSize)
        
        addBlankAudioInstructionAtTimeRange(timeRange,
                                            composition: composition)
        
        let introInstruction = AVMutableVideoCompositionInstruction()
        introInstruction.timeRange = CMTimeRangeMake(startTime, atTime)
        introInstruction.backgroundColor = UIColor(red: 228/255, green: 63/255, blue: 107/255, alpha: 1).CGColor
        introInstruction.layerInstructions = [layerInstruction]
        
        return (introInstruction, atTime)
    }
    
    
    private func addPromptSceneAtTime(inout atTime: CMTime,
                                            parentLayer: CALayer,
                                            allAreLayer: CALayer,
                                            videoSize: CGSize) -> CALayer {
        var promptLayer: CALayer!
        var promptImageLayer: CALayer!
        var companyLogoLayer: CALayer!
        var companyNameTextLayer: CATextLayer!
        
        self.moveLayer(allAreLayer,
                       duration: 0.25,
                       beginTime: atTime.seconds,
                       fromPoint: allAreLayer.position,
                       toPoint: CGPoint(x: -allAreLayer.frame.width, y: allAreLayer.position.y))
        
        promptLayer = CALayer()
        promptLayer.frame = CGRect(origin: CGPoint(x: parentLayer.frame.width, y: 0), size: parentLayer.frame.size)
        promptLayer.backgroundColor = UIColor(red: 90/255, green: 214/255, blue: 219/255, alpha: 1).CGColor
        promptLayer.opacity = 0.0
        
        parentLayer.addSublayer(promptLayer)
        
        let promptImage = UIImage(named: "prompts6.png")!.resizeImage(newHeight: videoSize.height)
        promptImageLayer = CALayer()
        promptImageLayer.contents = promptImage.CGImage
        promptImageLayer.frame = CGRect(origin: .zero, size: promptImage.size)
        promptImageLayer.masksToBounds = true
        promptLayer.addSublayer(promptImageLayer)
        
        companyLogoLayer = imageLayer("company-logo.png")
        companyLogoLayer.frame = CGRect(origin: CGPoint(x: promptImageLayer.frame.maxX + 40, y: 40.0),
                                        size: CGSize(width: 80, height: 80))
        companyLogoLayer.masksToBounds = true
        promptLayer.addSublayer(companyLogoLayer)
        
        companyNameTextLayer = CATextLayer()
        companyNameTextLayer.string = "COMPANY NAME"
        companyNameTextLayer.fontSize = 40
        
        companyNameTextLayer.frame = CGRect(origin: .zero, size: CGSize(width: promptLayer.bounds.width, height: companyNameTextLayer.fontSize + 10))
        companyNameTextLayer.anchorPoint = CGPoint(x: 0, y: 0.5)
        companyNameTextLayer.position = CGPoint(x: companyLogoLayer.frame.maxX + 10, y: companyLogoLayer.position.y)
        companyNameTextLayer.font = self.font1
        companyNameTextLayer.foregroundColor = UIColor.blackColor().CGColor
        promptLayer.addSublayer(companyNameTextLayer)
        
        self.hideLayer(promptLayer,
                       hidden: false,
                       duration: 0,
                       beginTime: atTime.seconds)
        self.moveLayer(promptLayer,
                       duration: 0.25,
                       beginTime: atTime.seconds,
                       fromPoint: promptLayer.position,
                       toPoint: CGPoint(x: parentLayer.frame.width/2, y: parentLayer.frame.height/2))
        
        atTime = CMTimeAdd(atTime, CMTimeMake(1, kCMTimeZero.timescale))
        
        self.hideLayer(allAreLayer,
                       hidden: true,
                       duration: 0,
                       beginTime: atTime.seconds)
        
        
        
        let promptTextLayer = CATextLayer()
        promptTextLayer.string = "Tell me one secrect which the others in your team don't know?"
        promptTextLayer.font = self.font1
        promptTextLayer.wrapped = true
        promptTextLayer.fontSize = 40
        promptTextLayer.frame = CGRect(x: 0,
                                       y: 0,
                                       width: promptLayer.bounds.width - promptImageLayer.bounds.width - 50,
                                       height: 200)
        promptTextLayer.anchorPoint = CGPoint(x: 0, y: 1)
        promptTextLayer.position = CGPoint(x: -promptLayer.bounds.width,
                                           y: promptLayer.bounds.height - 80)
        promptTextLayer.alignmentMode = kCAAlignmentLeft
        promptTextLayer.foregroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1).CGColor
        promptTextLayer.opacity = 0.0
        promptLayer.addSublayer(promptTextLayer)
        
        self.hideLayer(promptTextLayer,
                       hidden: false,
                       duration: 0,
                       beginTime: atTime.seconds)
        
        self.moveLayer(promptTextLayer,
                       duration: 0.25,
                       beginTime: atTime.seconds,
                       fromPoint: promptTextLayer.position,
                       toPoint: CGPoint(x: promptImageLayer.frame.maxX + 40,
                        y: promptTextLayer.position.y),
                       damping: true)
        
        atTime = CMTimeAdd(atTime, CMTimeMake(5, kCMTimeZero.timescale))
        
        ////////////////////////////////////////////////
        let duration = 0.5
        self.moveLayer(promptTextLayer,
                       duration: duration,
                       beginTime: atTime.seconds,
                       fromPoint: promptTextLayer.position,
                       toPoint: CGPoint(x: -promptTextLayer.bounds.width,
                        y: promptTextLayer.position.y),
                       damping: true)
        
        self.moveLayer(companyLogoLayer,
                       duration: duration,
                       beginTime: atTime.seconds,
                       fromPoint: companyLogoLayer.position,
                       toPoint: CGPoint(x: companyLogoLayer.position.x, y: -companyLogoLayer.bounds.height),
                       damping: true)
        
        self.moveLayer(companyNameTextLayer,
                       duration: duration,
                       beginTime: atTime.seconds,
                       fromPoint: companyNameTextLayer.position,
                       toPoint: CGPoint(x: companyNameTextLayer.position.x, y: -companyNameTextLayer.bounds.height),
                       damping: true)
        
        
        atTime = CMTimeAdd(atTime, CMTimeMake(1, kCMTimeZero.timescale))
        
        self.hideLayer(companyNameTextLayer,
                       hidden: true,
                       duration: 0,
                       beginTime: atTime.seconds)
        self.hideLayer(companyLogoLayer,
                       hidden: true, duration: 0,
                       beginTime: atTime.seconds)
        self.hideLayer(promptTextLayer,
                       hidden: true, duration: 0,
                       beginTime: atTime.seconds)
        
        
        let promptPeopleReact = CATextLayer()
        promptPeopleReact.font = self.font1
        promptPeopleReact.wrapped = true
        promptPeopleReact.fontSize = 60
        promptPeopleReact.string = "Let see how people react…"
        promptPeopleReact.frame = CGRect(origin: .zero,
                                         size: CGSize(width: promptLayer.bounds.width - promptImageLayer.bounds.width - 70, height: 200.0))
        promptPeopleReact.anchorPoint = CGPoint(x: 0, y: 0.5)
        promptPeopleReact.position = CGPoint(x: -promptPeopleReact.bounds.width, y: promptLayer.bounds.height/2)
        promptPeopleReact.opacity = 0.0
        promptPeopleReact.alignmentMode = kCAAlignmentLeft
        promptLayer.addSublayer(promptPeopleReact)
        
        self.hideLayer(promptPeopleReact,
                       hidden: false,
                       duration: 0,
                       beginTime: atTime.seconds)
        moveLayer(promptPeopleReact,
                  duration: duration,
                  beginTime: atTime.seconds,
                  fromPoint: promptPeopleReact.position,
                  toPoint: CGPoint(x: promptImageLayer.frame.maxX + 40, y: promptPeopleReact.position.y),
                  damping: true)
        
        atTime = CMTimeAdd(atTime, CMTimeMake(3, kCMTimeZero.timescale))
        
        return promptLayer
    }
    
    
    private func addReactionsAndWithAtTime(inout atTime: CMTime,
                                                 parentLayer: CALayer,
                                                 allAreLayer: CALayer,
                                                 allAreTextLayer: CATextLayer,
                                                 textFontSize: CGFloat) {
        let reactionsTextLayer = CATextLayer()
        reactionsTextLayer.string = "reactions"
        reactionsTextLayer.font = self.font1
        reactionsTextLayer.fontSize = textFontSize
        reactionsTextLayer.frame = CGRect(x: 0,
                                          y: parentLayer.frame.height/2 - 10 - textFontSize,
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
                       fromPoint: allAreTextLayer.position,
                       toPoint: CGPoint(x: allAreTextLayer.frame.width/4 - 50, y: allAreTextLayer.position.y))
        
        self.hideLayer(reactionsTextLayer, hidden: false, duration: 0, beginTime: atTime.seconds)
        self.moveLayer(reactionsTextLayer,
                       duration: 0.25,
                       beginTime: atTime.seconds,
                       fromPoint: reactionsTextLayer.position,
                       toPoint: CGPoint(x: allAreLayer.frame.width/2, y: allAreLayer.frame.height/2))
        
        atTime = CMTimeAdd(atTime, CMTimeMake(1, kCMTimeZero.timescale))
        
        
        let withTextLayer = CATextLayer()
        withTextLayer.string = "with"
        withTextLayer.font = self.font1
        withTextLayer.fontSize = textFontSize
        withTextLayer.frame = CGRect(x: 0,
                                     y: parentLayer.frame.height/2 - 10 - textFontSize,
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
                       fromPoint: withTextLayer.position,
                       toPoint: CGPoint(x: allAreLayer.frame.width*3/4 + 20, y: withTextLayer.position.y))
        atTime = CMTimeAdd(atTime, CMTimeMake(1, kCMTimeZero.timescale))
        
    }
}


extension MergeVideosViewController {
    private func handler(asset: AVAsset?, url: NSURL?, error: NSError?) {
        self.loadingVC.dismissViewControllerAnimated(true, completion: { _ in
            if let url = url {
                let player = AVPlayer(URL: url)
                self.playerController.player = player
                self.playerController
                self.presentViewController(self.playerController, animated: true, completion: { _ in
                    self.playerController.player?.play()
                })
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
                                                                  frame: CGRect(origin: .zero, size: DefaultVideoItemSize)) //TODO:
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
        
        let blankAudioURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("audio-1", ofType: "mp3")!)
        blankAudioAsset = AVAsset(URL: blankAudioURL)
        
        let applauseAudioURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("applause", ofType: "mp3")!)
        applauseAudioAsset = AVAsset(URL: applauseAudioURL)
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
                                                     frame: CGRect) -> AVMutableVideoCompositionLayerInstruction {
        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        if fixRotate {
            let assetTrack = asset.tracksWithMediaType(AVMediaTypeVideo)[0]
            let transform = assetTrack.preferredTransform
            let assetInfo = orientationFromTransform(transform)
            
            debugPrint("Asset nature size: \(assetTrack.naturalSize)")
            
            var scaleToFitRatio = frame.width / assetTrack.naturalSize.width
            var layerTransfrom: CGAffineTransform!
            debugPrint("Scale ratio: \(scaleToFitRatio)")
            if assetInfo.isPortrait {
                scaleToFitRatio = frame.width / assetTrack.naturalSize.height
                let scaleFactor = CGAffineTransformMakeScale(scaleToFitRatio, scaleToFitRatio)
                layerTransfrom = CGAffineTransformConcat(assetTrack.preferredTransform, scaleFactor)
            } else {
                let scaleFactor = CGAffineTransformMakeScale(scaleToFitRatio, scaleToFitRatio)
                if assetInfo.orientation == .Down {
                    let fixUpsideDown = CGAffineTransformMakeRotation(CGFloat(M_PI))
                    let windowBounds = CGRect(origin: .zero, size: frame.size)
                    let yFix = assetTrack.naturalSize.height + windowBounds.height
                    let centerFix = CGAffineTransformMakeTranslation(assetTrack.naturalSize.width, yFix)
                    layerTransfrom = CGAffineTransformConcat(CGAffineTransformConcat(fixUpsideDown, centerFix), scaleFactor)
                } else {
                    layerTransfrom = scaleFactor
                }
            }
            let postionTransfrom = CGAffineTransformMakeTranslation(frame.minX, frame.minY)
            layerTransfrom = CGAffineTransformConcat(layerTransfrom, postionTransfrom)
            instruction.setTransform(layerTransfrom, atTime: kCMTimeZero)
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
