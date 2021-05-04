//
//  CPKOverlayedImageView.swift
//  CupertinoKit
//
//  Created by Mayil Kannan on 22/12/20.
//  Copyright © 2020 CupertinoKit. All rights reserved.
//

import SwiftUI

struct CPKOverlayedImageView<Content: View>: View {
    
    let overlayStyle: CPKOverlayedImageViewStyleProtocol
    let backgroundRectangle = Rectangle()
    var content: Content
    var contentMode: ContentMode
    @Binding var image: UIImage
    
    init(overlayStyle: CPKOverlayedImageViewStyleProtocol = DefaultOverlayStyle(),
         image: Binding<UIImage>,
         contentMode: ContentMode = .fill,
         @ViewBuilder content: () -> Content) {
        self.overlayStyle = overlayStyle
        self._image = image
        self.contentMode = contentMode
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                backgroundRectangle
                    .edgesIgnoringSafeArea(.all)
                    .foregroundColor(overlayStyle.imageAppearance == .dark ? .black : .white)
                    .opacity(overlayStyle.imageOpacity)
                    .onTapGesture {
                    }
                content
            }
        }
    }
}
