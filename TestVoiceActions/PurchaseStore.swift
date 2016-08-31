//
//  PurchaseManager.swift
//  TestVoiceActions
//
//  Created by Le Tai on 8/25/16.
//  Copyright © 2016 Snowball. All rights reserved.
//

import StoreKit

typealias ProductIdentifier = String
typealias ProductsRequestCompletionHandler = (success: Bool, products: [SKProduct]?) -> ()

public class PurchaseStore : NSObject  {
    static let PurchaseStorePurchaseNotification = "PurchaseStorePurchaseNotification"
    
    var purchasedProductIdentifiers: Set<ProductIdentifier>! = []
    var productIdentifiers: Set<ProductIdentifier>!
    var productsRequest: SKProductsRequest?
    var productsRequestCompletionHandler: ProductsRequestCompletionHandler?
    
    init(productIds: Set<ProductIdentifier>) {
        super.init()
        //Add observer
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        self.productIdentifiers = productIds
        
        for productId in productIds {
            //TODO: Should load from our-backend
            let purchased = NSUserDefaults.standardUserDefaults().boolForKey(productId)
            if purchased {
                purchasedProductIdentifiers.insert(productId)
                debugPrint("Product purchased: \(productId)")
            } else {
                debugPrint("Product not purchased: \(productId)")
            }
        }
    }
    
    deinit {
        SKPaymentQueue.defaultQueue().removeTransactionObserver(self)
    }
}

// MARK: - StoreKit API

extension PurchaseStore {
    func requestProducts(completionHandler: ProductsRequestCompletionHandler) {
        productsRequest?.cancel()
        productsRequestCompletionHandler = completionHandler
        
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest!.delegate = self
        productsRequest!.start()
    }
    
    func buyProduct(product: SKProduct) {
        debugPrint("Buying product: \(product.productIdentifier)")
        let payment = SKPayment(product: product)
        SKPaymentQueue.defaultQueue().addPayment(payment)
    }
    
    func isProductPurchased(productIdentifier: ProductIdentifier) -> Bool {
        return purchasedProductIdentifiers.contains(productIdentifier)
    }
    
    func restorePurchases() {
        SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
    }
    
    class func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
}

// MARK: - SKProductsRequestDelegate

extension PurchaseStore: SKProductsRequestDelegate {
    public func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        debugPrint("Loaded list of products...")
        let products = response.products
        productsRequestCompletionHandler?(success: true, products: products)
        clearRequestAndHandler()
        
        for product in products {
            debugPrint("Found product: \(product.productIdentifier) \(product.localizedTitle) \(product.price.floatValue)")
        }
    }
    
    public func request(request: SKRequest, didFailWithError error: NSError) {
        debugPrint("Failed to load list of products.")
        debugPrint("Error: \(error.localizedDescription)")
        productsRequestCompletionHandler?(success: false, products: nil)
        clearRequestAndHandler()
    }
    
    private func clearRequestAndHandler() {
        productsRequest = nil
        productsRequestCompletionHandler = nil
    }
}

// MARK: - SKPaymentTransactionObserver

extension PurchaseStore: SKPaymentTransactionObserver {
    public func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .Purchasing:
                debugPrint("Purchasing product: \(transaction.payment.productIdentifier)")
            case .Purchased:
                completeTransaction(transaction)
            case .Failed:
                failedTransaction(transaction)
            case .Restored:
                restoreTransaction(transaction)
            case .Deferred:
                break //TODO: For parent manage, can test it
            }
        }
    }
    
    private func completeTransaction(transaction: SKPaymentTransaction) {
        debugPrint("Purchased product: \(transaction.payment.productIdentifier)")
        deliverPurchaseNotificatioForIdentifier(transaction.payment.productIdentifier)
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
    }
    
    private func restoreTransaction(transaction: SKPaymentTransaction) {
        guard let productIdentifier = transaction.originalTransaction?.payment.productIdentifier else { return }
        debugPrint("Restore product \(productIdentifier)")
        deliverPurchaseNotificatioForIdentifier(productIdentifier)
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
    }
    
    private func failedTransaction(transaction: SKPaymentTransaction) {
        debugPrint("failedTransaction...")
        if transaction.error!.code != SKErrorCode.PaymentCancelled.rawValue {
            debugPrint("Transaction Error: \(transaction.error?.localizedDescription)")
        }
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
    }
    
    private func deliverPurchaseNotificatioForIdentifier(identifier: String?) {
        guard let identifier = identifier else { return }
        purchasedProductIdentifiers.insert(identifier)
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: identifier)
        NSUserDefaults.standardUserDefaults().synchronize()
        NSNotificationCenter.defaultCenter().postNotificationName(PurchaseStore.PurchaseStorePurchaseNotification, object: identifier)
    }
}