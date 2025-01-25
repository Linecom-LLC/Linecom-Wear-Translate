//
//  ExtensionDelegate.swift
//  Linecom Wear Translate v2 Watch App
//
//  Created by 程炜栋 on 2025/1/26.
//

import Foundation
import WatchKit
import SwiftyStoreKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    func applicationDidFinishLaunching() {
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
                for purchase in purchases {
                    switch purchase.transaction.transactionState {
                    case .purchased, .restored:
                        if purchase.needsFinishTransaction {
                            // Deliver content from server, then:
                            SwiftyStoreKit.finishTransaction(purchase.transaction)
                        }
                        // Unlock content
                    case .failed, .purchasing, .deferred:
                        break // do nothing
                    }
                }
            }
    }
}
