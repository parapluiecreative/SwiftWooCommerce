//
//  CPKCarouselView.swift
//  CupertinoKit
//
//  Created by Mayil Kannan on 23/12/20.
//  Copyright © 2020 CupertinoKit. All rights reserved.
//

import SwiftUI

fileprivate class CarouselConfig: ObservableObject {
    @Published var cardWidth: CGFloat = 0
    @Published var cardCount: Int = 0
    @Published var selected: Int = 0
}

struct CPKCarouselView<Cards: View>: View {
    let cards: Cards
    private var config: CarouselConfig
    @GestureState private var isDetectingLongPress = false
    @State private var offset: CGFloat = 0
    @State private var gestureOffset: CGFloat = 0
    private let spacing: CGFloat
    
    init(
        cardWidth: CGFloat, selected: Int = 0, spacing: CGFloat = 20,
        @ViewBuilder cards: @escaping () -> Cards
    ) {
        self.config = CarouselConfig()
        self.config.cardWidth = cardWidth
        self.config.selected = selected
        self.spacing = spacing
        self.cards = cards()
    }
    
    func offset(for index: Int, geometry: GeometryProxy) -> CGFloat {
        return (geometry.size.width - self.config.cardWidth) / 2 - CGFloat(self.config.selected)
            * (self.config.cardWidth + spacing)
    }
    
    var body: some View {
        GeometryReader {
            geometry in
            HStack(alignment: .center, spacing: self.spacing) {
                cards
                    .environmentObject(config)
            }
            .offset(x: offset + gestureOffset)
            .onAppear {
                self.offset = self.offset(for: self.config.selected, geometry: geometry)
            }
            .gesture(
                DragGesture().updating($isDetectingLongPress) { currentState, gestureState, transaction in
                    DispatchQueue.main.async {
                        self.gestureOffset = currentState.translation.width
                    }
                }.onEnded { value in
                    self.offset += self.gestureOffset
                    self.gestureOffset = 0
                    if value.translation.width < -(geometry.size.width / 6) {
                        self.config.selected = min(self.config.selected + 1, self.config.cardCount - 1)
                    } else if value.translation.width > (geometry.size.width / 6) {
                        self.config.selected = max(0, self.config.selected - 1)
                    }
                    withAnimation(.easeOut(duration: 0.3)) {
                        print(self.config.selected)
                        self.offset = self.offset(for: self.config.selected, geometry: geometry)
                    }
                })
        }
    }
}

struct CarouselCard<Content: View>: View {
    @EnvironmentObject fileprivate var config: CarouselConfig
    let content: Content
    @State private var cardId: Int? = nil
    var isActive: Bool {
        return cardId == config.cardCount - config.selected - 1
    }
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .frame(width: config.cardWidth)
            .scaleEffect(isActive ? 1 : 0.8)
            .animation(.easeInOut, value: isActive)
            .zIndex(isActive ? 1 : 0)
            .onAppear {
                self.cardId = self.config.cardCount
                self.config.cardCount += 1
            }.onDisappear {
                self.config.cardCount -= 1
            }
    }
}
