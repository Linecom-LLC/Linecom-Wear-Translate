import SwiftUI
import SwiftyStoreKit

struct SubscriptionConfig {
    static let productIds: Set<String> = [
        "com.linecom.weartranslate.subscription.monthly",
        "com.linecom.weartranslate.subscription.yearly"
    ]
}

struct SubscriptionProduct: Identifiable {
    let id: String
    let title: String
    let description: String
    let price: String
}

final class SubscriptionStore: ObservableObject {
    @Published var products: [SubscriptionProduct] = []
    @Published var isLoading = false
    @Published var isPurchasing = false
    @Published var isSubscribed = false
    @Published var message = ""

    private let subscribedKey = "IsSubscribed"
    private let subscribedProductKey = "SubscriptionProductId"

    func load() {
        isLoading = true
        message = ""

        SwiftyStoreKit.retrieveProductsInfo(SubscriptionConfig.productIds) { result in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = result.error {
                    self.message = "订阅项目加载失败：\(error.localizedDescription)"
                    return
                }

                let fetchedProducts = result.retrievedProducts.map {
                    SubscriptionProduct(
                        id: $0.productId,
                        title: $0.localizedTitle,
                        description: $0.localizedDescription,
                        price: $0.localizedPrice ?? "--"
                    )
                }

                self.products = fetchedProducts.sorted { $0.title < $1.title }
                if fetchedProducts.isEmpty {
                    self.message = "当前没有可用订阅项目"
                }
            }
        }
    }

    func purchase(productId: String) {
        isPurchasing = true
        message = ""

        SwiftyStoreKit.purchaseProduct(productId, quantity: 1, atomically: true) { result in
            DispatchQueue.main.async {
                self.isPurchasing = false
                switch result {
                case .success:
                    self.isSubscribed = true
                    UserDefaults.standard.set(true, forKey: self.subscribedKey)
                    UserDefaults.standard.set(productId, forKey: self.subscribedProductKey)
                    self.message = "订阅成功，翻译功能已解锁"
                case .error(let error):
                    if error.code == .paymentCancelled {
                        self.message = "已取消订阅"
                    } else {
                        self.message = "订阅失败：\(error.localizedDescription)"
                    }
                case .deferred(purchase: _):
                    self.message = "订阅请求待处理"
                }
            }
        }
    }

    func restore() {
        isLoading = true
        message = ""

        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            DispatchQueue.main.async {
                self.isLoading = false
                if results.restoreFailedPurchases.count > 0 {
                    self.message = "恢复购买失败"
                    return
                }

                let hasSubscription = results.restoredPurchases.contains {
                    SubscriptionConfig.productIds.contains($0.productId)
                }

                if hasSubscription {
                    self.isSubscribed = true
                    UserDefaults.standard.set(true, forKey: self.subscribedKey)
                    UserDefaults.standard.set(results.restoredPurchases.first(where: {
                        SubscriptionConfig.productIds.contains($0.productId)
                    })?.productId ?? "", forKey: self.subscribedProductKey)
                    self.message = "已恢复订阅"
                } else {
                    self.message = "未找到可恢复的订阅"
                }
            }
        }
    }

    func syncStatusFromStorage() {
        isSubscribed = UserDefaults.standard.bool(forKey: subscribedKey)
    }
}

struct SubscriptionView: View {
    @StateObject private var store = SubscriptionStore()

    var body: some View {
        List {
            Section {
                HStack {
                    Image(systemName: store.isSubscribed ? "checkmark.seal.fill" : "xmark.seal")
                        .foregroundColor(store.isSubscribed ? .green : .orange)
                    Text(store.isSubscribed ? "已订阅" : "未订阅")
                }
            } header: {
                Text("订阅状态")
            }

            Section {
                if store.isLoading {
                    ProgressView("正在加载订阅项目")
                } else {
                    ForEach(store.products) { product in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(product.title)
                            Text(product.description)
                                .font(.caption2)
                                .foregroundColor(.gray)
                            Text(product.price)
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        .padding(.vertical, 2)

                        Button("订阅") {
                            store.purchase(productId: product.id)
                        }
                        .disabled(store.isPurchasing)
                    }
                }
            } header: {
                Text("可用订阅")
            }

            Section {
                Button("恢复购买") {
                    store.restore()
                }
                .disabled(store.isLoading || store.isPurchasing)

                Button("刷新项目") {
                    store.load()
                }
                .disabled(store.isLoading || store.isPurchasing)
            }

            if !store.message.isEmpty {
                Section {
                    Text(store.message)
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
        }
        .onAppear {
            store.syncStatusFromStorage()
            store.load()
        }
    }
}

#Preview {
    SubscriptionView()
}
