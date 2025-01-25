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
    @State public var isLoading: Bool = false
    @AppStorage("Subscription.Type") var subscriptionType: Int?
    
    @State var BasicMonthlyPrice: String = "--"
    @State var BasicYearlyPrice: String = "--"
    
    @State var ProWeeklyPrice: String = "--"
    @State var ProMonthlyPrice: String = "--"
    @State var ProYearlyPrice: String = "--"
    
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        NavigationStack {
            if !isLogin {
                IDLoginRequiredView()
            } else {
                List {
//                    Section(content: {
//                        PurchaseItem(pid: "com.linecom.weartranslate.basic.monthly")
//                        PurchaseItem(pid: "com.linecom.weartranslate.basic.yearly")
//                    }, header: {Text("基本版订阅")})
//                    
//                    Section(content: {
//                        PurchaseItem(pid: "com.linecom.weartranslate.pro.weekly")
//                        PurchaseItem(pid: "com.linecom.weartranslate.pro.monthly")
//                        PurchaseItem(pid: "com.linecom.weartranslate.pro.yearly")
//                    }, header: {Text("高级版订阅")})
//                    
//                    Divider()
//                    
//                    Section(content: {
//                        PurchaseItem(pid: "com.linecom.weartranslate.noOLS")
//                    }, header: {Text("买断版")})
                    
                    Section {
                        VStack {
                            HStack {
                                Text("免费版")
                                    .font(.title2)
                                Spacer()
                            }
                            .padding(.bottom, 2)
                            HStack {
                                Image(systemName: "minus.circle")
                                Text("每月仅能翻译20句")
                                Spacer()
                            }
                            .foregroundColor(.gray)
                            .padding(.bottom, 2)
                            
                            HStack {
                                Image(systemName: "minus.circle")
                                Text("无更多翻译服务")
                                Spacer()
                            }
                            .foregroundColor(.gray)
                        }
                    }
                    
                    Section {
                        VStack {
                            HStack {
                                Text("Basic")
                                    .font(.title2)
                                Spacer()
                            }
                            .padding(.bottom, 2)
                            
                            HStack {
                                Image(systemName: "checkmark.circle")
                                Text("无限制使用3个翻译提供商")
                                Spacer()
                            }
                            .foregroundColor(.blue)
                            .padding(.bottom, 2)
                            
                            HStack {
                                Image(systemName: "character.circle")
                                Text("30句文言文翻译")
                                Spacer()
                            }
                            .foregroundColor(.blue)
                            .padding(.bottom, 2)
                            
                            HStack {
                                Image(systemName: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                                Text("同步50条历史记录")
                                Spacer()
                            }
                            .foregroundColor(.blue)
                            .padding(.bottom, 2)
                            
                            HStack {
                                Image(systemName: "minus.circle")
                                Text("无高级翻译提供商")
                                Spacer()
                            }
                            .foregroundColor(.gray)
                        }
                        
                        Button(action: {
                            Task {
                                isLoading = true
                                let purchaseResult = await PurchaseCore().pruchaseProduct(pid: "com.linecom.weartranslate.basic.monthly")
                                isLoading = false
                            }
                        }, label: {
                            if isLoading {
                                ProgressView()
                                    .padding()
                            } else {
                                Text("以 \(BasicMonthlyPrice) /月订阅")
                            }
                        })
                        .disabled(isLoading)
                        
                        Button(action: {
                            Task {
                                isLoading = true
                                let purchaseResult = await PurchaseCore().pruchaseProduct(pid: "com.linecom.weartranslate.basic.yearly")
                                isLoading = false
                            }
                        }, label: {
                            if isLoading {
                                ProgressView()
                                    .padding()
                            } else {
                                Text("以 \(BasicYearlyPrice) /年订阅")
                            }
                        })
                        .disabled(isLoading)
                    }
                    .onAppear() {
                        Task {
                            isLoading = true
                            BasicMonthlyPrice = await PurchaseCore().getPrice(pid: "com.linecom.weartranslate.basic.monthly") ?? "--"
                            BasicYearlyPrice = await PurchaseCore().getPrice(pid: "com.linecom.weartranslate.basic.yearly") ?? "--"
                            isLoading = false
                        }
                    }
                    
                    Section {
                        VStack {
                            HStack {
                                Text("Pro")
                                    .font(.title2)
                                Spacer()
                            }
                            .padding(.bottom, 2)
                            
                            HStack {
                                Image(systemName: "checkmark.circle")
                                Text("无限制使用5个翻译提供商")
                                Spacer()
                            }
                            .foregroundColor(.yellow)
                            .padding(.bottom, 2)
                            
                            HStack {
                                Image(systemName: "character.circle")
                                Text("50句文言文翻译")
                                Spacer()
                            }
                            .foregroundColor(.yellow)
                            .padding(.bottom, 2)
                            
                            HStack {
                                Image(systemName: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                                Text("不受限制的历史记录同步")
                                Spacer()
                            }
                            .foregroundColor(.yellow)
                            .padding(.bottom, 2)
                            
                            HStack {
                                Image(systemName: "star.circle")
                                Text("高级翻译提供商")
                                Spacer()
                            }
                            .foregroundColor(.yellow)
                        }
                        
                        Button(action: {
                            Task {
                                isLoading = true
                                let purchaseResult = await PurchaseCore().pruchaseProduct(pid: "com.linecom.weartranslate.basic.monthly")
                                isLoading = false
                            }
                        }, label: {
                            if isLoading {
                                ProgressView()
                                    .padding()
                            } else {
                                Text("以 \(ProWeeklyPrice) /周订阅")
                            }
                        })
                        .disabled(isLoading)
                        
                        Button(action: {
                            Task {
                                isLoading = true
                                let purchaseResult = await PurchaseCore().pruchaseProduct(pid: "com.linecom.weartranslate.basic.monthly")
                                isLoading = false
                            }
                        }, label: {
                            if isLoading {
                                ProgressView()
                                    .padding()
                            } else {
                                Text("以 \(ProMonthlyPrice) /月订阅")
                            }
                        })
                        .disabled(isLoading)
                        
                        Button(action: {
                            Task {
                                isLoading = true
                                let purchaseResult = await PurchaseCore().pruchaseProduct(pid: "com.linecom.weartranslate.basic.yearly")
                                isLoading = false
                            }
                        }, label: {
                            if isLoading {
                                ProgressView()
                                    .padding()
                            } else {
                                Text("以 \(ProYearlyPrice) /年订阅")
                            }
                        })
                        .disabled(isLoading)
                    }
                    .onAppear() {
                        Task {
                            isLoading = true
                            BasicMonthlyPrice = await PurchaseCore().getPrice(pid: "com.linecom.weartranslate.basic.monthly") ?? "--"
                            BasicYearlyPrice = await PurchaseCore().getPrice(pid: "com.linecom.weartranslate.basic.yearly") ?? "--"
                            ProWeeklyPrice = await PurchaseCore().getPrice(pid: "com.linecom.weartranslate.pro.weekly") ?? "--"
                            ProMonthlyPrice = await PurchaseCore().getPrice(pid: "com.linecom.weartranslate.pro.monthly") ?? "--"
                            ProYearlyPrice = await PurchaseCore().getPrice(pid: "com.linecom.weartranslate.pro.yearly") ?? "--"
                            isLoading = false
                        }
                    }
                }
            }
        }
    }
}

//struct PurchaseItem: View {
//    var pid: String
//    @State var Loading: Bool = true
//    @State var Purchasing: Bool = false
//    @State var productInfo: ProductInfo?
//    
//    var body: some View {
//        if Loading {
//            HStack {
//                ProgressView()
//                Text("正在加载...")
//            }
//            .onAppear() {
//                Task {
//                    productInfo = await PurchaseCore().getProductInfo(pid: pid)
//                    Loading = false
//                }
//            }
//        } else {
//            VStack {
//                Text(productInfo?.localizedTitle ?? "获取失败")
//                    .font(.title3)
//                Text(productInfo?.localizedDescription ?? "获取失败")
//                    .font(.caption)
//                Button(action: {
//                    Purchasing = true
//                    PurchaseView().isPurchasing = true
//                    Task {
//                        await PurchaseCore().pruchaseProduct(pid: pid)
//                        Purchasing = false
//                        PurchaseView().isPurchasing = false
//                    }
//                }, label: {
//                    if Purchasing {
//                        ProgressView()
//                            .padding()
//                    } else {
//                        Text("以 \(productInfo?.price ?? "--") /月 订阅")
//                            .padding()
//                    }
//                })
//                .background(.blue)
//                .cornerRadius(5)
//                .padding()
//                .disabled(Purchasing)
//            }
//        }
//    }
//}

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
