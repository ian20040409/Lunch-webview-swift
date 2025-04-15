import SwiftUI
import WebKit

// 封裝 WKWebView 的 UIViewRepresentable
struct WebView: UIViewRepresentable {
    let webView: WKWebView
    
    func makeUIView(context: Context) -> WKWebView {
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // 無需更新
    }
}

// 為了避免因 WKWebView 不是 Sendable 的警告，將 ContentView 限制在主執行緒上
@MainActor
struct ContentView: View {
    @State private var webView = WKWebView()
    @State private var showShareSheet = false
    @State private var showExportView = false
    @State private var isLongPressing = false
    @State private var showToolbar = true  // 控制工具列顯示
    
    let url = URL(string: "https://ian20040409.github.io/Lunch-Navigator-web-2025/")!
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            WebView(webView: webView)
                .onAppear {
                    let request = URLRequest(url: url)
                    webView.load(request)
                }
            
            // 工具列（浮動或隱藏後顯示小按鈕）
            if showToolbar {
                VStack(spacing: 20) {
                    // 重新整理按鈕
                    Button(action: {
                        webView.reload()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    
                    // 分享按鈕（加入長按手勢觸發 ExportView）
                    Button(action: {
                        showShareSheet = true
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .scaleEffect(isLongPressing ? 1.3 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: isLongPressing)
                    }
                    .simultaneousGesture(
                        LongPressGesture(minimumDuration: 1.5)
                            .onChanged { _ in
                                withAnimation { isLongPressing = true }
                            }
                            .onEnded { _ in
                                isLongPressing = false
                                showExportView = true
                            }
                    )
                    
                    // 隱藏工具列按鈕
                    Button(action: {
                        withAnimation { showToolbar = false }
                    }) {
                        Image(systemName: "eye.slash")
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .padding(.trailing, 20)
                .padding(.bottom, 40)
                .shadow(radius: 5)
            } else {
                // 工具列隱藏時顯示的小按鈕
                Button(action: {
                    withAnimation { showToolbar = true }
                }) {
                   // Image(systemName: "eye")
                    Image(systemName: "ellipsis.circle")
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 40)
            }
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .sheet(isPresented: $showShareSheet) {
            if let shareURL = webView.url {
                ShareSheet(activityItems: [shareURL])
            }
        }
        // 利用 .sheet 呈現 ExportView (ExportView.swift 中定義)
        .sheet(isPresented: $showExportView) {
            ExportView()
        }
    }
}

// UIKit 分享控制器包裝
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
