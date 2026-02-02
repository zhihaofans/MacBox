//
//  SidebarView.swift
//  MacBox
//
//  Created by zzh on 2026/2/1.
//

import SwiftUI

enum SidebarItem: String, CaseIterable, Hashable, Identifiable {
    case home = "首页"
    case setting = "设置"

    var id: String {
        rawValue
    }

    var icon: String {
        switch self {
        case .home: return "house"
        case .setting: return "gear"
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
