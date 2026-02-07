//
//  TextToTextTool.swift
//  MacBox
//
//  Created by zzh on 2026/2/3.
//

import SwiftUI
import SwiftUtils

struct TextToTextTool: View {
    var type: SidebarItem

    var body: some View {
        switch type {
        case .textTool_base64text:
//            Text("Base64")
            TexttoTextView(type)
        default:
            Text("还不支持")
        }
    }

    init(_ type: SidebarItem) {
        self.type = type
    }
}

private struct TexttoTextView: View {
    var type: SidebarItem
    @State private var inputText: String = ""
    @State private var outputText: String = ""
    @State private var isEncode: Bool = true
    init(_ type: SidebarItem) {
        self.type = type
    }

    var body: some View {
        VStack(spacing: 16) {
            // 顶部配置区
            HStack {
                Text(type.rawValue)
                    .font(.title2)
                    .bold()

                Spacer()

                Toggle(isOn: $isEncode) {
                    Text(isEncode ? "编码" : "解码")
                }
                .toggleStyle(.switch)
            }

            // 输入区
            editorCard(
                title: "输入",
                text: $inputText,
                showPaste: true
            )

            // 输出区
            editorCard(
                title: "输出",
                text: $outputText,
                showCopy: true
            )
        }
        .setNavigationTitle(type.rawValue)
        .padding(20)
        .onChange(of: inputText) {
            convert()
        }
        .onChange(of: isEncode) {
            convert()
        }
    }

    func convert() {
        switch type {
        case .textTool_base64text:
            if inputText.isNotEmpty {
                if isEncode {
                    outputText = inputText.base64Encode
                } else {
                    outputText = inputText.base64Decode
                }
            }

        default:
            outputText = ""
        }
    }

    func editorCard(
        title: String,
        text: Binding<String>,
        showPaste: Bool = false,
        showCopy: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.headline)

                Spacer()

                if showPaste {
                    Button("粘贴") {
                        if let str = NSPasteboard.general.string(forType: .string) {
                            text.wrappedValue = str
                        }
                    }
                }

                if showCopy {
                    Button("复制") {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(text.wrappedValue, forType: .string)
                    }
                }
            }

            TextEditor(text: text)
                .font(.system(.body, design: .monospaced))
                .frame(minHeight: 200)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(NSColor.textBackgroundColor))
                )
        }
    }
}
