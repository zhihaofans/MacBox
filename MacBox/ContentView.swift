//
//  ContentView.swift
//  MacBox
//
//  Created by zzh on 2025/11/14.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedSidebar: SidebarItem? = .home
    var body: some View {
        NavigationSplitView {
            SidebarView(selected: $selectedSidebar)
        } detail: {
            NavigationStack {
                switch selectedSidebar {
                    case .textTool_base64text:
                        TextToTextTool(.textTool_base64text)
                    default:
                        Text("Hello, nil!")
                }
            }
        }
        .navigationSplitViewStyle(.prominentDetail)
    }
}
