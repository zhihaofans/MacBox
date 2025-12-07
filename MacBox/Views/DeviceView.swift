//
//  DeviceView.swift
//  MacBox
//
//  Created by zzh on 2025/11/23.
//

import SwiftUI

struct DeviceView: View {
    let items = [
        ("查看设备信息", "info.circle"),
        ("监控 CPU/内存", "gauge"),
        ("网络信息", "network")
    ]

    struct DeviceInfoView: View {
        var body: some View {
            Text("设备信息页面")
                .padding()
        }
    }

    struct DeviceMonitorView: View {
        var body: some View {
            Text("CPU / 内存监控页面")
                .padding()
        }
    }

    struct NetworkInfoView: View {
        var body: some View {
            Text("网络信息页面")
                .padding()
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("设备相关工具")
                .font(.title2)
                .bold()

            ForEach(items, id: \.0) { item in
                NavigationLink {
                    switch item.0 {
                    case "查看设备信息":
                        DeviceInfoView()
                    case "监控 CPU/内存":
                        DeviceMonitorView()
                    case "网络信息":
                        NetworkInfoView()
                    default:
                        EmptyView()
                    }
                } label: {
                    HStack {
                        Image(systemName: item.1)
                        Text(item.0)
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }

            Spacer()
        }
        .padding()
    }
}
