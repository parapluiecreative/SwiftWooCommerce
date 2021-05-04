//
//  CPKToastView.swift
//  CupertinoKit
//
//  Created by Mayil Kannan on 01/12/20.
//  Copyright © 2020 CupertinoKit. All rights reserved.
//

import SwiftUI

extension View {
    func toast(isPresented: Binding<Bool>, text: String, systemImageName: String = "", buttonName: String = "", buttonAction: @escaping (() -> ()) = { }) -> some View {
        CPKToastView(
            isPresented: isPresented,
            presenter: { self }
        ) {
            HStack {
                Text(text)
                    .foregroundColor(.white)
                    .padding(.leading, 10)
                if !systemImageName.isEmpty || !buttonName.isEmpty {
                    Spacer()
                    Divider()
                        .background(Color.white)
                        .padding(.trailing, 10)
                    if !systemImageName.isEmpty {
                        Image(systemName: systemImageName)
                            .padding(.trailing, 10)
                            .foregroundColor(.white)
                    }
                    if !buttonName.isEmpty {
                        Button(action: buttonAction) {
                            Text(buttonName)
                                .foregroundColor(.white)
                                .padding(.trailing, 10)
                        }
                    }
                }
            }
        }
    }
}

struct CPKToastView<Presenting, Content>: View where Presenting: View, Content: View {
    @Binding var isPresented: Bool
    let presenter: () -> Presenting
    let delay: TimeInterval = 2
    let content: () -> Content
    
    var body: some View {
        if self.isPresented {
            DispatchQueue.main.asyncAfter(deadline: .now() + self.delay) {
                withAnimation {
                    self.isPresented = false
                }
            }
        }
        
        return GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                self.presenter()
                ZStack {
                    Rectangle()
                        .fill(Color.black)
                        .cornerRadius(10)
                        .opacity(0.7)
                    self.content()
                }
                .frame(width: geometry.size.width - 20, height: 55)
                .opacity(self.isPresented ? 1 : 0)
            }
            .padding(.bottom)
        }
    }
}
