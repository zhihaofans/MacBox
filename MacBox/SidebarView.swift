//
//  SidebarView.swift
//  MacBox
//
//  Created by zzh on 2026/2/1.
//

import SwiftUI

enum SidebarItem: String, CaseIterable, Hashable, Identifiable {
    case home = "首页"
    case textTool_base64text = "Base64文本编码/解码"
    case textTool_urlencode = "URL编码/解码"
    case setting = "设置"

    var id: String {
        rawValue
    }

    var icon: String {
        switch self {
        case .home: return "house"
        case .setting: return "gear"
        case .textTool_base64text: return "46.square"
        case .textTool_urlencode: return "link.badge.plus"
        }
    }
}

struct SidebarView: View {
    @Binding var selected: SidebarItem?

    var body: some View {
        List(SidebarItem.allCases, selection: $selected) { item in
            Label(item.rawValue, systemImage: item.icon)
                .tag(item)
        }
        .listStyle(.sidebar)
    }
}
