//
//  CPKOverlayView.swift
//  CupertinoKit
//
//  Created by Mayil Kannan on 18/12/20.
//  Copyright © 2020 CupertinoKit. All rights reserved.
//

import SwiftUI

struct CPKOverlayView<Parent: View, Content: View>: View {
    
    let overlayStyle: CPKOverlayStyleProtocol
    let backgroundRectangle = Rectangle()
    var parent: Parent
    var content: Content
    @Binding var isPresented: Bool
    
    init(overlayStyle: CPKOverlayStyleProtocol, isPresented: Binding<Bool>, parent: Parent, @ViewBuilder content: () -> Content) {
        self.overlayStyle = overlayStyle
        self._isPresented = isPresented
        self.parent = parent
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            parent
            if isPresented {
                backgroundRectangle
                    .edgesIgnoringSafeArea(.all)
                    .foregroundColor(overlayStyle.appearance == .dark ? .black : .white)
                    .opacity(overlayStyle.opacity)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onTapGesture {
                        isPresented = false
                    }
                content
            }
        }
    }
}

extension View {
    func overlayView<OverlayBody: View>(overlayStyle: CPKOverlayStyleProtocol = DefaultOverlayStyle(),
                                        isPresented: Binding<Bool>,
                                        @ViewBuilder overlayBody: () -> OverlayBody) -> some View {
        CPKOverlayView(overlayStyle: overlayStyle, isPresented: isPresented, parent: self, content: overlayBody)
    }
}

struct DefaultOverlayStyle: CPKOverlayStyleProtocol, CPKOverlayedImageViewStyleProtocol {
    var imageAppearance: CPKOverlayedImageViewStyleAppearance = .dark
    var imageOpacity: Double = 0.3
    var appearance: CPKOverlayStyleAppearance = .dark
    var opacity: Double = 0.3
}
