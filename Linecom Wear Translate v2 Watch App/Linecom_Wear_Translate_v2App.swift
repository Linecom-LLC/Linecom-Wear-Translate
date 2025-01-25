//
//  Linecom_Wear_Translate_v2App.swift
//  Linecom Wear Translate v2 Watch App
//
//  Created by 程炜栋 on 2025/1/25.
//

import SwiftUI
import WatchKit

@main
struct Linecom_Wear_Translate_v2_Watch_AppApp: App {
    @WKExtensionDelegateAdaptor var delegate: ExtensionDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
