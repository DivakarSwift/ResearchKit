//
//  PromptCollectionViewController.swift
//  TestVoiceActions
//
//  Created by Le Tai on 8/25/16.
//  Copyright © 2016 Snowball. All rights reserved.
//

import UIKit


final class PromptCollectionViewController: UICollectionViewController {
    
    var shakeManager: ShakeManager!
    var currentIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.scrollEnabled = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        shakeManager = ShakeManager()
        currentIndex = 0
        
        shakeManager.shakeLeft = {
            guard self.currentIndex > 0 else {
                ShakeManager.vibrate()
                return
            }
            self.currentIndex = self.currentIndex - 1
            self.collectionView?.scrollToItemAtIndexPath(NSIndexPath(forItem: self.currentIndex, inSection: 0), atScrollPosition: .None, animated: true)
        }
        
        shakeManager.shakeRight = {
            guard self.currentIndex < 4 else {
                ShakeManager.vibrate()
                return
            }
            self.currentIndex = self.currentIndex + 1
            self.collectionView?.scrollToItemAtIndexPath(NSIndexPath(forItem: self.currentIndex, inSection: 0), atScrollPosition: .None, animated: true)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        shakeManager = nil
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PromptCellectuonViewCell", forIndexPath: indexPath) as! PromptCellectuonViewCell
        
        cell.promptImageView.image = UIImage(named: "p\(indexPath.row+1).png")
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView,
                          layout collectionViewLayout: UICollectionViewLayout,
                                 sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return view.frame.size
    }
}

final class PromptCellectuonViewCell: UICollectionViewCell {
    @IBOutlet weak var promptImageView: UIImageView!
    
}
