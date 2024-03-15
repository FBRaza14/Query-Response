//
//  ScreenShotView.swift
//  Query_Response
//
//  Created by Ahmad Azam on 14/03/2024.
//
import SwiftUI


struct ScreenShotAnimationView: View {
    
    @StateObject private var viewModel = GenderViewModel()
    
    @Namespace var namespace
    @State var image: UIImage?
    @Binding var showScreenShot: Bool
    @State var showFullImage = false
    @State var showSmallImage = false
    @State var trailingBtnCoordinate: CGPoint = .zero
    
    var body: some View {
        GeometryReader {
            reader in
            ZStack {
                VStack(alignment: .center) {
                    if let image = image, showFullImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .opacity(1)
                            .matchedGeometryEffect(id: "image", in: namespace)
                    }
                    if let image = image, showSmallImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80,height: 80)
                            .rotationEffect(.degrees(35))
                            .opacity(0.5)
                            .matchedGeometryEffect(id: "image", in: namespace)
                            .position(x: trailingBtnCoordinate.x, y: trailingBtnCoordinate.y)
                    }
                }
                .onChange(of: showScreenShot) { newValue in
                    if newValue {
                        trailingBtnCoordinate = CGPoint(x: reader.size.width - 40, y: reader.frame(in: .global).minY - 40)
                        image = captureScreenshot()
                        if let image {
                            ScreenshotManager.shared.saveScreenshotToDocumentDirectory(image: image)
                        }
                        showFullImage = true
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation(.linear(duration: 0.5)) {
                                showFullImage = false
                                showSmallImage = true
                            }
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                            withAnimation {
                                showSmallImage = false
                                image = nil
                                showScreenShot = false
                            }
                        }
                    }
                }
                }
                .frame(width: reader.size.width, height: reader.size.height, alignment: .center)
        }
    }
    
    func captureScreenshot() -> UIImage {
        // Function to capture the screenshot of the screen
        // You can use your preferred method to capture the screenshot here
        let window = UIApplication.shared.windows.first { $0.isKeyWindow }
        let bounds = window?.frame ?? UIScreen.main.bounds
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { context in
            window?.layer.render(in: context.cgContext)
        }
    }
}
