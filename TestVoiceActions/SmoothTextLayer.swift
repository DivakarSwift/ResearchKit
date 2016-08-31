//
//  SmoothTextLayer.swift
//  TestVoiceActions
//
//  Created by Le Tai on 8/29/16.
//  Copyright © 2016 Snowball. All rights reserved.
//

import UIKit

class SmoothTextLayer: CATextLayer {
    override func drawInContext(ctx: CGContext) {
//        CGContextSetRGBFillColor(ctx, 255, 255, 255, 0)
//        CGContextFillRect(ctx, bounds)
//        CGContextSetShouldSmoothFonts(ctx, true)
//        
        
        CGContextSetAllowsAntialiasing(ctx, true)
        CGContextSetAllowsFontSmoothing(ctx, true)
        CGContextSetAllowsFontSubpixelPositioning(ctx, true)
        CGContextSetAllowsFontSubpixelQuantization(ctx, true)
        
        CGContextSetStrokeColorWithColor(ctx, self.foregroundColor)
        CGContextSetFillColorWithColor(ctx, self.backgroundColor)
        CGContextFillRect(ctx, self.bounds)
        
        CGContextSetShouldAntialias(ctx, true)
        CGContextSetShouldSmoothFonts(ctx, true)
        CGContextSetShouldSubpixelPositionFonts(ctx, true)
        CGContextSetShouldSubpixelQuantizeFonts(ctx, true)
        
        super.drawInContext(ctx)
    }
}
