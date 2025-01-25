//
//  PurchaseView.swift
//  Linecom Wear Translate v2 Watch App
//
//  Created by 程炜栋 on 2025/1/25.
//

import SwiftUI
import SwiftyStoreKit

struct PurchaseView: View {
    @AppStorage("LinecomID.isLogin") var isLogin = true
    @State public var isPurchasing: Bool = false
    var body: some View {
        NavigationStack {
            if !isLogin {
                IDLoginRequiredView()
            } else {
                if isPurchasing {
                    ZStack {
                        Color.black.opacity(0.5)
                        ProgressView()
                    }
                }
                List {
                    Section(content: {
                        PurchaseItem(pid: "com.linecom.weartranslate.basic.monthly")
                        PurchaseItem(pid: "com.linecom.weartranslate.basic.yearly")
                    }, header: {Text("基本版订阅")})
                    
                    Section(content: {
                        PurchaseItem(pid: "com.linecom.weartranslate.pro.weekly")
                        PurchaseItem(pid: "com.linecom.weartranslate.pro.monthly")
                        PurchaseItem(pid: "com.linecom.weartranslate.pro.yearly")
                    }, header: {Text("高级版订阅")})
                    
                    Divider()
                    
                    Section(content: {
                        PurchaseItem(pid: "com.linecom.weartranslate.noOLS")
                    }, header: {Text("买断版")})
                }
            }
        }
    }
}

struct PurchaseItem: View {
    var pid: String
    @State var Loading: Bool = true
    @State var Purchasing: Bool = false
    @State var productInfo: ProductInfo?
    
    var body: some View {
        if Loading {
            HStack {
                ProgressView()
                Text("正在加载...")
            }
            .onAppear() {
                Task {
                    productInfo = await PurchaseCore().getProductInfo(pid: pid)
                    Loading = false
                }
            }
        } else {
            VStack {
                Text(productInfo?.localizedTitle ?? "获取失败")
                    .font(.title3)
                Text(productInfo?.localizedDescription ?? "获取失败")
                    .font(.caption)
                Button(action: {
                    Purchasing = true
                    PurchaseView().isPurchasing = true
                    Task {
                        await PurchaseCore().pruchaseProduct(pid: pid)
                        Purchasing = false
                        PurchaseView().isPurchasing = false
                    }
                }, label: {
                    if Purchasing {
                        ProgressView()
                            .padding()
                    } else {
                        Text(productInfo?.price ?? "--")
                            .padding()
                    }
                })
                .background(.blue)
                .cornerRadius(5)
                .padding()
                .disabled(Purchasing)
            }
        }
    }
}

struct IDLoginRequiredView: View {
    var body: some View {
        VStack {
            Image(systemName: "person.crop.circle.fill.badge.xmark")
                .resizable()
                .scaledToFit()
                .padding()
            Text("请登录 Linecom ID 后再执行购买")
                .font(.caption)
                .multilineTextAlignment(.center)
            NavigationLink(destination: LinecomIDLoginView()) {
                Text("登录 Linecom ID")
            }
            .padding()
        }
    }
}

#Preview {
    PurchaseView()
}
