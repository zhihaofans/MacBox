//
//  ContentView.swift
//  MacBox
//
//  Created by zzh on 2025/11/14.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 160), spacing: 20)
                ], spacing: 20) {
                    ForEach(tools) { tool in
                        NavigationLink {
                            ToolDetailView(tool: tool)
                        } label: {
                            VStack(spacing: 12) {
                                Image(systemName: tool.icon)
                                    .font(.system(size: 36))
                                Text(tool.name)
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity, minHeight: 120)
                            .padding()
                            .background(Color.secondary.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("工具箱")
        }
    }
}
