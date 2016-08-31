//
//  DrawingViewController.swift
//  TestVoiceActions
//
//  Created by Le Tai on 8/26/16.
//  Copyright © 2016 Snowball. All rights reserved.
//

import UIKit

class DrawingViewController: UIViewController {
    
    @IBOutlet weak var progressLabel: UILabel!
    
    @IBOutlet weak var circleWrapperView: UIView!
    var circleDrawingView: DrawingView!
    
    @IBOutlet weak var squareWrapperView: UIView!
    var squareDrawingView: DrawingView!
    
    @IBOutlet weak var sliderView: UISlider!

    override func viewDidLoad() {
        super.viewDidLoad()
        circleDrawingView = DrawingView(frame: circleWrapperView.bounds, shapeType: .Circle)
        circleWrapperView.addSubview(circleDrawingView)
        
        squareDrawingView = DrawingView(frame: squareWrapperView.bounds, shapeType: .Square(radius: 20))
        squareWrapperView.addSubview(squareDrawingView)
    }
    
    @IBAction func sliderViewDidChange(sliderView: UISlider) {
        let progress = sliderView.value
        circleDrawingView.setProgress(progress)
        squareDrawingView.setProgress(progress)
        progressLabel.text = String(format: "%0.2f", progress)
    }
}
