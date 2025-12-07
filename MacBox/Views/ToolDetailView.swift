//
//  ToolDetailView.swift
//  MacBox
//
//  Created by zzh on 2025/11/21.
//

import SwiftUI

struct Tool: Identifiable {
    let id: String
    let name: String
    let icon: String
}

// 示例工具数组
let tools: [Tool] = [
    Tool(id: "decive", name: "设备信息", icon: "list.dash"),
]

struct ToolDetailView: View {
    let tool: Tool
    @State private var showAlert = false

    var body: some View {
        VStack(spacing: 0) {
            // 根据工具显示不同视图
            switch tool.id {
            case "decive":
                DeviceView()
            default:
                Spacer()
                    .onAppear {
                        showAlert = true
                    }
                    .alert("工具未实现", isPresented: $showAlert) {
                        Button("确定") {}
                    }
            }

            Spacer()
        }
        .navigationTitle(tool.name)
    }
}
