//
//  WebViewDisplay.swift
//  Query_Response
//
//  Created by Ahmad Azam on 14/03/2024.
//

import SwiftUI
import WebKit

struct WebView: View {
    @State private var showScreenShot = false
    let htmlContent: String

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                WebViewWrapper(htmlContent: htmlContent)
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
            ScreenShotAnimationView(showScreenShot: $showScreenShot)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // Take screenshot after 1.0 seconds of webview appear.
                withAnimation {
                    showScreenShot = true
                }
            }
        }
    }
}

struct WebView_Previews: PreviewProvider {
    static var previews: some View {
        WebView(htmlContent: "")
    }
}


// MARK: - Wrapper For Web view:

struct WebViewWrapper: UIViewRepresentable {
    let htmlContent: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.loadHTMLString(htmlContent, baseURL: nil)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(htmlContent, baseURL: nil)
    }
}
