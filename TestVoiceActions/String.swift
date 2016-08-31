//
//  String.swift
//  TestVoiceActions
//
//  Created by Le Tai on 8/31/16.
//  Copyright © 2016 Snowball. All rights reserved.
//

import UIKit

extension String {
    func sizeWithFont(font: UIFont, forWidth width: CGFloat) -> CGSize {
        let fString = self as NSString
        let maximumSize = CGSize(width: width, height: CGFloat(MAXFLOAT))
        let rect = fString.boundingRectWithSize(maximumSize,
                                                options: NSStringDrawingOptions.TruncatesLastVisibleLine.union(NSStringDrawingOptions.UsesLineFragmentOrigin),
                                                attributes: [NSFontAttributeName: font],
                                                context: nil)
        return rect.size
    }
}
