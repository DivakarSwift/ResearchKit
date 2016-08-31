//
//  PurchaseTableViewController.swift
//  TestVoiceActions
//
//  Created by Le Tai on 8/25/16.
//  Copyright © 2016 Snowball. All rights reserved.
//

import UIKit
import StoreKit

class PurchaseTableViewController: UITableViewController {
    
    var products = [SKProduct]()
    var retrieving = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 55
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PurchaseTableViewController.handlePurchaseNotification(_:)), name: PurchaseStore.PurchaseStorePurchaseNotification, object: nil)
        
        loadPurchases()
        PurchaseProducts.store.restorePurchases()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(PurchaseTableViewController.refresh), forControlEvents: .ValueChanged)
    }
    
}

extension PurchaseTableViewController {
    func handlePurchaseNotification(notification: NSNotification) {
        guard let productId = notification.object as? String,
            index = products.indexOf({ $0.productIdentifier == productId }) else { return }
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Fade)
    }
    
    func loadPurchases() {
        retrieving = true
        refreshControl?.beginRefreshing()
        PurchaseProducts.store.requestProducts { (success, products) in
            guard let products = products else { return }
            self.products = products
            debugPrint("Number of products: \(products.count)")
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
            self.retrieving = false
        }
    }
    
    func refresh() {
        guard !retrieving else { return }
        loadPurchases()
    }
}

extension PurchaseTableViewController {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PurchaseTableViewCell", forIndexPath: indexPath) as! PurchaseTableViewCell
        cell.product = products[indexPath.row]
        cell.buyHandler = { product in
            PurchaseProducts.store.buyProduct(product)
        }
        
//        if indexPath.row == 0 {
//            cell.buyButton.hidden = true
//            cell.checkmarkImageView.hidden = true
//            cell.pendingImageView.hidden = true
//            cell.canMakePaymentImageView.hidden = false
//        }
//        if indexPath.row == 3 {
//            cell.buyButton.hidden = true
//            cell.checkmarkImageView.hidden = true
//            cell.pendingImageView.hidden = false
//            cell.canMakePaymentImageView.hidden = true
//        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

class PurchaseTableViewCell: UITableViewCell {
    static let priceFormatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        
        formatter.formatterBehavior = .Behavior10_4
        formatter.numberStyle = .CurrencyStyle
        
        return formatter
    }()
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var checkmarkImageView: UIImageView!
    @IBOutlet weak var canMakePaymentImageView: UIImageView!
    @IBOutlet weak var pendingImageView: UIImageView!
    
    var product: SKProduct! {
        didSet {
            titleLabel.text = product.localizedTitle
            PurchaseTableViewCell.priceFormatter.locale = product.priceLocale
            detailLabel.text = "Price: \(PurchaseTableViewCell.priceFormatter.stringFromNumber(product.price)!)\nDescriptions: \(product.localizedDescription)"
            
            let canMakePayments = PurchaseStore.canMakePayments()
            canMakePaymentImageView.hidden = canMakePayments
            if canMakePayments {
                let purchased = PurchaseProducts.store.isProductPurchased(product.productIdentifier)
                buyButton.hidden = purchased
                checkmarkImageView.hidden = !purchased
                canMakePaymentImageView.hidden = true
            }
        }
    }
    
    var buyHandler: ((SKProduct) -> Void)?
    
    @IBAction func buyButtonTapped(button: UIButton) {
        buyHandler?(product)
    }
}


