//
//  PurchaseProducts.swift
//  TestVoiceActions
//
//  Created by Le Tai on 8/25/16.
//  Copyright © 2016 Snowball. All rights reserved.
//

import UIKit

struct PurchaseProducts {
    static let Prefix = "com.levantAJ.Testing."
    static let ChangeLogo = Prefix + "change_logo"
    static let Export10Videos = Prefix + "export_ten_videos"
    static let ExportVideoWithTransitions = "export_video_with_transitions"
    static let AddEmoticons = Prefix + "AddEmoticons"
    static let AddAudioForExportingVideos = Prefix + "AddAudioForExportingVideos"
    static let AddFiltersForYourVideos = Prefix + "AddFiltersForYourVideos"
    static let BuyMeIfYouCan = Prefix + "BuyMeIfYouCan"
    
    static let productIdentifiers: Set<ProductIdentifier> = [ExportVideoWithTransitions, Export10Videos, ChangeLogo, AddEmoticons, AddAudioForExportingVideos, AddFiltersForYourVideos, BuyMeIfYouCan]
    
    static let store = PurchaseStore(productIds: PurchaseProducts.productIdentifiers)
}