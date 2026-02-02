//
//  MacBoxApp.swift
//  MacBox
//
//  Created by zzh on 2025/11/14.
//

import AppKit
import SwiftUI
import SwiftUtils

@main
struct MacBoxApp: App {
    // 这个加了之后，关闭最后一个窗口时，应用会退出
    @NSApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    init() {
        SU.configureLogger(label: "github.zhihaofans.macbox")
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(
        _ sender: NSApplication
    ) -> Bool {
        true
    }
}
