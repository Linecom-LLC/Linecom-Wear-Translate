//
//  PurchaseCore.swift
//  Linecom Wear Translate v2 Watch App
//
//  Created by 程炜栋 on 2025/1/25.
//

import Foundation
import SwiftyStoreKit

class PurchaseCore {
    @MainActor
    func getProductInfo(pid: String) async -> ProductInfo? {
        return await withCheckedContinuation { continuation in
            SwiftyStoreKit.retrieveProductsInfo([pid]) { result in
                if let product = result.retrievedProducts.first {
                    let priceString = product.localizedPrice ?? ""
                    print("Fetched Product: \(product.localizedDescription), price: \(priceString)")
                    
                    let productInfo = ProductInfo(
                        id: pid,
                        localizedTitle: product.localizedTitle,
                        localizedDescription: product.localizedDescription,
                        price: priceString
                    )
                    continuation.resume(returning: productInfo)
                } else if let invalidProductId = result.invalidProductIDs.first {
                    print("Invalid product identifier: \(invalidProductId)")
                    continuation.resume(returning: nil)
                } else {
                    print("Error: \(String(describing: result.error))")
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
    func getPrice(pid: String) async -> String? {
        return await withCheckedContinuation { continuation in
            SwiftyStoreKit.retrieveProductsInfo([pid]) { result in
                if let product = result.retrievedProducts.first {
                    let priceString = product.localizedPrice ?? ""
                    print("Fetched Product: \(product.localizedDescription), price: \(priceString)")
                    
                    let productInfo = ProductInfo(
                        id: pid,
                        localizedTitle: product.localizedTitle,
                        localizedDescription: product.localizedDescription,
                        price: priceString
                    )
                    continuation.resume(returning: priceString)
                } else if let invalidProductId = result.invalidProductIDs.first {
                    print("Invalid product identifier: \(invalidProductId)")
                    continuation.resume(returning: nil)
                } else {
                    print("Error: \(String(describing: result.error))")
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
    func pruchaseProduct(pid: String) async -> Bool {
        
        return await withCheckedContinuation { continuation in
            SwiftyStoreKit.purchaseProduct(pid, quantity: 1, atomically: true) { result in
                switch result {
                case .success(let purchase):
                    print("Purchase Success: \(purchase.productId)")
                    continuation.resume(returning: true)
                case .error(let error):
                    switch error.code {
                    case .unknown: print("Unknown error. Please contact support"); continuation.resume(returning: false)
                    case .clientInvalid: print("Not allowed to make the payment"); continuation.resume(returning: false)
                    case .paymentCancelled: break
                    case .paymentInvalid: print("The purchase identifier was invalid"); continuation.resume(returning: false)
                    case .paymentNotAllowed: print("The device is not allowed to make the payment"); continuation.resume(returning: false)
                    case .storeProductNotAvailable: print("The product is not available in the current storefront"); continuation.resume(returning: false)
                    case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed"); continuation.resume(returning: false)
                    case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network"); continuation.resume(returning: false)
                    case .cloudServiceRevoked: print("User has revoked permission to use this cloud service"); continuation.resume(returning: false)
                    default: print((error as NSError).localizedDescription); continuation.resume(returning: false)
                    }
                case .deferred(purchase: let purchase):
                    break
                }
            }
        }
        
    }
    
    func CheckPurchaseState(pid: String) -> Bool {
        var isPurchased = false
        var error = ""
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: "your-shared-secret")
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case .success(let receipt):
                let productId = pid
                // Verify the purchase of Consumable or NonConsumable
                let purchaseResult = SwiftyStoreKit.verifyPurchase(
                    productId: productId,
                    inReceipt: receipt)
                    
                switch purchaseResult {
                case .purchased(let receiptItem):
                    isPurchased = true
                    print("\(productId) is purchased: \(receiptItem)")
                case .notPurchased:
                    print("The user has never purchased \(productId)")
                }
            case .error(let err):
                error = err.localizedDescription
                print("Receipt verification failed: \(err)")
            }
        }
        
        return isPurchased
    }
}

struct ProductInfo: Codable {
    var id: String
    var localizedTitle: String
    var localizedDescription: String
    var price: String
    
    init(id: String, localizedTitle: String, localizedDescription: String, price: String) {
        self.id = id
        self.localizedTitle = localizedTitle
        self.localizedDescription = localizedDescription
        self.price = price
    }
}

struct SubscriptionInfo: Codable, Identifiable {
    var id: String
    var expiryDate: Date
}
