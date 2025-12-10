//
//  DeviceView.swift
//  MacBox
//
//  Created by zzh on 2025/11/23.
//

import Combine
import CoreWLAN
import Darwin
import Network
import SwiftUI
import SystemConfiguration

struct InfoRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

struct DeviceView: View {
    let items = [
        ("查看设备信息", "info.circle"),
        ("监控 CPU/内存", "gauge"),
        ("网络信息", "network")
    ]

    struct DeviceInfoView: View {
        var deviceName: String {
            Host.current().localizedName ?? "未知设备"
        }

        var systemVersion: String {
            ProcessInfo.processInfo.operatingSystemVersionString
        }

        var cpuCount: Int {
            ProcessInfo.processInfo.processorCount
        }

        var memoryGB: String {
            let bytes = ProcessInfo.processInfo.physicalMemory
            return String(format: "%.1f GB", Double(bytes) / 1024 / 1024 / 1024)
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                Text("设备信息")
                    .font(.title2)
                    .bold()

                InfoRow(title: "设备名称", value: deviceName)
                InfoRow(title: "系统版本", value: systemVersion)
                InfoRow(title: "CPU 核心数", value: "\(cpuCount)")
                InfoRow(title: "内存容量", value: memoryGB)

                Spacer()
            }
            .padding()
        }
    }

    struct DeviceMonitorView: View {
        @State private var cpuUsage: Double = 0
        @State private var memoryUsage: Double = 0

        let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

        var body: some View {
            VStack(alignment: .leading, spacing: 20) {
                Text("实时监控")
                    .font(.title2)
                    .bold()

                ProgressView("CPU 使用率: \(Int(cpuUsage))%", value: cpuUsage, total: 100)
                ProgressView("内存使用率: \(Int(memoryUsage))%", value: memoryUsage, total: 100)

                Spacer()
            }
            .padding()
            .onReceive(timer) { _ in
                cpuUsage = getCPUUsage()
                memoryUsage = getMemoryUsage()
            }
        }

        func getCPUUsage() -> Double {
            var count = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info_data_t>.size / MemoryLayout<integer_t>.size)
            var info = host_cpu_load_info()

            let result = withUnsafeMutablePointer(to: &info) {
                $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                    host_statistics(
                        mach_host_self(),
                        HOST_CPU_LOAD_INFO,
                        $0,
                        &count
                    )
                }
            }

            guard result == KERN_SUCCESS else { return 0 }

            let totalTicks =
                Double(info.cpu_ticks.0) +
                Double(info.cpu_ticks.1) +
                Double(info.cpu_ticks.2) +
                Double(info.cpu_ticks.3)

            let idleTicks = Double(info.cpu_ticks.2)

            return (1 - idleTicks / totalTicks) * 100
        }

        func getMemoryUsage() -> Double {
            let total = Double(ProcessInfo.processInfo.physicalMemory)
            let used = total * 0.65
            return used / total * 100
        }
    }

    struct NetworkInfoView: View {
        @State private var ip: String = "-"
        @State private var wifiName: String = "-"
        @State private var mac: String = "-"
        @State private var externalIP: String = "-"

        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                Text("网络信息")
                    .font(.title2)
                    .bold()

                InfoRow(title: "本地 IP", value: ip)
                InfoRow(title: "Wi-Fi 名称", value: wifiName)
                InfoRow(title: "MAC 地址", value: mac)
                InfoRow(title: "外网 IP", value: externalIP)

                Spacer()
            }
            .padding()
            .onAppear {
                ip = getLocalIP() ?? "-"
                wifiName = getWiFiName() ?? "-"
                mac = getMACAddress() ?? "-"
                getExternalIP { self.externalIP = $0 }
            }
        }

        func getLocalIP() -> String? {
            var address: String?
            let monitor = NWPathMonitor()
            let queue = DispatchQueue(label: "IPQueue")
            monitor.pathUpdateHandler = { path in
                if path.status == .satisfied {
                    for interface in path.availableInterfaces {
                        if interface.type == .wifi {
                            address = interface.debugDescription
                        }
                    }
                }
            }
            monitor.start(queue: queue)
            return address
        }

        func getWiFiName() -> String? {
            CWWiFiClient.shared().interface()?.ssid()
        }

        func getMACAddress() -> String? {
            return "00:00:00:00:00:00"
        }

        func getExternalIP(_ completion: @escaping (String) -> Void) {
            let url = URL(string: "https://api.ipify.org")!
            URLSession.shared.dataTask(with: url) { data, _, _ in
                completion(String(data: data ?? Data(), encoding: .utf8) ?? "-")
            }.resume()
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
