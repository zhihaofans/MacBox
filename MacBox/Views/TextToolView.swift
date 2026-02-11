//
//  TextToTextTool.swift
//  MacBox
//
//  Created by zzh on 2026/2/3.
//

import SwiftUI
import SwiftUtils

struct TextToolView: View {
    var type: SidebarItem

    var body: some View {
        switch type {
        case .textTool_base64text, .textTool_urlencode:
            TextToTextView(type)
        case .textTool_base64image:
            TextToImageView(type)
        default:
            Text("还不支持")
        }
    }

    init(_ type: SidebarItem) {
        self.type = type
    }
}

private struct TextToTextView: View {
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

        case .textTool_urlencode:
            if inputText.isNotEmpty {
                if isEncode {
                    outputText = inputText.urlEncode
                } else {
                    outputText = inputText.urlDecode
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

private struct TextToImageView: View {
    var type: SidebarItem
    @State private var base64Text: String = ""
    @State private var image: NSImage? = nil
    init(_ type: SidebarItem) {
        self.type = type
    }

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(type.rawValue)
                        .font(.headline)
                    Spacer()
                    Button("粘贴") {
                        if let str = NSPasteboard.general.string(forType: .string) {
                            base64Text = str
                        }
                    }
                    Button("复制") {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(base64Text, forType: .string)
                    }
                }
                TextEditor(text: $base64Text)
                    .font(.system(.body, design: .monospaced))
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(NSColor.textBackgroundColor))
                    )
            }
            VStack(spacing: 16) {
                // 拖拽区域
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [6]))
                        .foregroundColor(.gray.opacity(0.4))

                    VStack {
                        Text("拖拽图片到此处")
                        Text("或粘贴")
                            .foregroundColor(.secondary)
                    }
                }
                .frame(height: 160)
                .onDrop(of: ["public.file-url"], isTargeted: nil) { providers in
                    loadImage(from: providers)
                }
                if let image {
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                        .cornerRadius(8)
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(NSColor.controlBackgroundColor))
                        .frame(height: 300)
                }
            }
        }
        .setNavigationTitle(type.rawValue)
        .padding(20)
        .onChange(of: base64Text) {
            decodeImage()
        }
    }

    func loadImage(from providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }

        provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { item, _ in
            DispatchQueue.main.async {
                if let data = item as? Data,
                   let url = URL(dataRepresentation: data, relativeTo: nil),
                   let image = NSImage(contentsOf: url)
                {
                    self.image = image
                    encodeImage()
                }
            }
        }

        return true
    }

    func encodeImage() {
        guard let image,
              let tiff = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiff),
              let data = bitmap.representation(using: .png, properties: [:])
        else { return }
        base64Text = data.base64EncodedString()
    }

    func decodeImage() {
        guard let img = QrcodeUtil().generateQRCode(from: base64Text)
        else {
            image = nil
            return
        }

        image = img
    }
}
