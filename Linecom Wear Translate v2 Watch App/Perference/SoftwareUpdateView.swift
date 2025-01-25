//
//  SoftwareUpdateView.swift
//  Linecom Wear Translate v2 Watch App
//
//  Created by 程炜栋 on 2025/1/25.
//

import SwiftUI

struct SoftwareUpdateView: View {
    #error("Not Completed")
    @AppStorage("") var isUpdate: Bool = false
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink(destination: PromptUpdateView()) {
                        Text("提示更新")
                    }
                }
            }
        }
    }
}

struct PromptUpdateView: View {
    var body: some View {
        List {
            Toggle("提示更新", isOn: .constant(true))
        }
    }
}

#Preview {
    SoftwareUpdateView()
}
