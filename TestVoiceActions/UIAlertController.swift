//
//  UIAlertController.swift
//  TestVoiceActions
//
//  Created by Le Tai on 8/29/16.
//  Copyright © 2016 Snowball. All rights reserved.
//

import UIKit

extension UIAlertController {
    class func loadingVC(title: String = "Loading…") -> UIAlertController {
        let alertVC = UIAlertController(title: nil, message: title, preferredStyle: .Alert)
        return alertVC
    }
}
