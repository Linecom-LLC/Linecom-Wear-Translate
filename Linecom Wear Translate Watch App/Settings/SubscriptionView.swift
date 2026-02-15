import SwiftUI
import SwiftyStoreKit

struct SubscriptionConfig {
    static let productIds: Set<String> = [
        "com.linecom.weartranslate.v2Basic.Monthly",
        "com.linecom.weartranslate.v2Basic.Yearly"
    ]
    static let manageSubscriptionsURL = URL(string: "https://apps.apple.com/account/subscriptions")!
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
    @Published var subscribedProductId = ""
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
                if fetchedProducts.isEmpty && !self.isSubscribed {
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
                    self.persistSubscription(productId: productId)
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

                if let restored = results.restoredPurchases.first(where: {
                    SubscriptionConfig.productIds.contains($0.productId)
                }) {
                    self.persistSubscription(productId: restored.productId)
                    self.message = "已恢复订阅"
                } else {
                    self.clearSubscription()
                    self.message = "未找到可恢复的订阅"
                }
            }
        }
    }

    func syncStatusFromStorage() {
        let productId = UserDefaults.standard.string(forKey: subscribedProductKey) ?? ""
        subscribedProductId = productId
        isSubscribed = SubscriptionConfig.productIds.contains(productId)
        UserDefaults.standard.set(isSubscribed, forKey: subscribedKey)
    }

    private func persistSubscription(productId: String) {
        subscribedProductId = productId
        isSubscribed = SubscriptionConfig.productIds.contains(productId)
        UserDefaults.standard.set(isSubscribed, forKey: subscribedKey)
        UserDefaults.standard.set(productId, forKey: subscribedProductKey)
    }

    private func clearSubscription() {
        subscribedProductId = ""
        isSubscribed = false
        UserDefaults.standard.set(false, forKey: subscribedKey)
        UserDefaults.standard.removeObject(forKey: subscribedProductKey)
    }
}

struct SubscriptionView: View {
    @StateObject private var store = SubscriptionStore()
    @Environment(\.openURL) private var openURL

    var body: some View {
        List {
            Section {
                HStack {
                    Image(systemName: store.isSubscribed ? "checkmark.seal.fill" : "xmark.seal")
                        .foregroundColor(store.isSubscribed ? .green : .orange)
                    Text(store.isSubscribed ? "已订阅" : "未订阅")
                }
                if store.isSubscribed {
                    Text("当前订阅：\(store.subscribedProductId)")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            } header: {
                Text("订阅状态")
            }

            if store.isSubscribed {
                Section {
                    Button("管理订阅") {
                        openURL(SubscriptionConfig.manageSubscriptionsURL)
                    }
                } footer: {
                    Text("将打开 App Store 订阅管理页面")
                }
            } else {
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
            }

            Section {
                Button("恢复购买") {
                    store.restore()
                }
                .disabled(store.isLoading || store.isPurchasing)

                Button("刷新项目") {
                    store.syncStatusFromStorage()
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
            if !store.isSubscribed {
                store.load()
            }
        }
    }
}

#Preview {
    SubscriptionView()
}
