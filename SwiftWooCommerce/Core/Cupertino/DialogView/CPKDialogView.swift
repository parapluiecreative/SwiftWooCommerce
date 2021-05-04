//
//  CPKDialogView.swift
//  CupertinoKit
//
//  Created by Mayil Kannan on 09/12/20.
//  Copyright © 2020 CupertinoKit. All rights reserved.
//

import SwiftUI

/// Modal View

struct CPKDialogModalView<Parent: View, Content: View>: View {
    @Environment(\.modalStyle) var style: CPKDialogModalStyle
    
    @Binding var isPresented: Bool
    
    var parent: Parent
    var content: Content
    
    let backgroundRectangle = Rectangle()
    
    // MARK: Body

    var body: some View {
        ZStack {
            parent
            
            if isPresented {
                // make background
                style.makeBackground(
                    configuration: ModalStyleBackgroundConfiguration(
                        background: backgroundRectangle
                    ),
                    isPresented: $isPresented
                )
                // make modal view
                style.makeModal(
                    configuration: ModalStyleModalContentConfiguration(
                        content: AnyView(content)
                    ),
                    isPresented: $isPresented
                ).transition(.move(edge: .bottom))
            }
        }
        .animation(style.animation)
    }
    
    init(isPresented: Binding<Bool>, parent: Parent, @ViewBuilder content: () -> Content) {
        self._isPresented = isPresented
        self.parent = parent
        self.content = content()
    }
}

extension View {
    func modal<ModalBody: View>(
            isPresented: Binding<Bool>,
            @ViewBuilder modalBody: () -> ModalBody
    ) -> some View {
        CPKDialogModalView(
            isPresented: isPresented,
            parent: self,
            content: modalBody
        )
    }
}

/// Modal Style

protocol CPKModalStyle {
    associatedtype Background: View
    associatedtype Modal: View
    
    var animation: Animation? { get }
    
    func makeBackground(configuration: BackgroundConfiguration, isPresented: Binding<Bool>) -> Background
    func makeModal(configuration: ModalContentConfiguration, isPresented: Binding<Bool>) -> Modal
    
    typealias BackgroundConfiguration = ModalStyleBackgroundConfiguration
    typealias ModalContentConfiguration = ModalStyleModalContentConfiguration
}

extension CPKModalStyle {
    func anyMakeBackground(configuration: BackgroundConfiguration, isPresented: Binding<Bool>) -> AnyView {
        AnyView(
            makeBackground(configuration: configuration, isPresented: isPresented)
        )
    }
    
    func anyMakeModal(configuration: ModalContentConfiguration, isPresented: Binding<Bool>) -> AnyView {
        AnyView(
            makeModal(configuration: configuration, isPresented: isPresented)
        )
    }
}

public struct CPKDialogModalStyle: CPKModalStyle {
    let animation: Animation?
    
    private let _makeBackground: (CPKModalStyle.BackgroundConfiguration, Binding<Bool>) -> AnyView
    private let _makeModal: (CPKModalStyle.ModalContentConfiguration, Binding<Bool>) -> AnyView
    
    init<Style: CPKModalStyle>(_ style: Style) {
        self.animation = style.animation
        self._makeBackground = style.anyMakeBackground
        self._makeModal = style.anyMakeModal
    }
    
    func makeBackground(configuration: CPKModalStyle.BackgroundConfiguration, isPresented: Binding<Bool>) -> AnyView {
        return self._makeBackground(configuration, isPresented)
    }
    
    func makeModal(configuration: CPKModalStyle.ModalContentConfiguration, isPresented: Binding<Bool>) -> AnyView {
        return self._makeModal(configuration, isPresented)
    }
}

struct ModalStyleKey: EnvironmentKey {
    public static let defaultValue: CPKDialogModalStyle = CPKDialogModalStyle(DefaultModalStyle())
}

extension EnvironmentValues {
    var modalStyle: CPKDialogModalStyle {
        get {
            return self[ModalStyleKey.self]
        }
        set {
            self[ModalStyleKey.self] = newValue
        }
    }
}

extension View {
    func modalStyle<Style: CPKModalStyle>(_ style: Style) -> some View {
        self
            .environment(\.modalStyle, CPKDialogModalStyle(style))
    }
}

/// Modal Style Configuration

struct ModalStyleBackgroundConfiguration {
    let background: Rectangle
}

struct ModalStyleModalContentConfiguration {
    let content: AnyView
}

/// Default Modal Style

struct DefaultModalStyle: CPKModalStyle {
    let animation: Animation? = .interpolatingSpring(mass: 0.85, stiffness: 100.0, damping: 10, initialVelocity: 0)
    
    func makeBackground(configuration: CPKModalStyle.BackgroundConfiguration, isPresented: Binding<Bool>) -> some View {
        configuration.background
            .edgesIgnoringSafeArea(.all)
            .foregroundColor(.black)
            .opacity(0.3)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .zIndex(1000)
            .onTapGesture {
                isPresented.wrappedValue = false
            }
    }
    
    func makeModal(configuration: CPKModalStyle.ModalContentConfiguration, isPresented: Binding<Bool>) -> some View {
        configuration.content
            .zIndex(1001)
    }
}

struct DetailView: View {
    
    enum ButtonStyle {
        case horizontal
        case vertical
    }
    
    enum ModelContentMode {
        case halfScreen
        case fullScreen
    }
    
    @Binding var isDisplayed: Bool
    
    var showCloseIcon: Bool
    var alertIcon: UIImage
    var alertTitle: String = ""
    var alertDescription: String = ""
    var primaryButtonIcon: UIImage? = nil
    var primaryButtonTitle: String = ""
    var secondaryButtonTitle: String = ""
    private let primaryButtonAction: ButtonAction?
    private let secondaryButtonAction: ButtonAction?
    typealias ButtonAction = () -> Void
    var buttonStyle: ButtonStyle = .vertical
    var alertTextFieldTitle: String = ""
    var modelContentMode: ModelContentMode = .halfScreen

    // primary button
    var primaryButton: some View {
        Button(action: {
            self.isDisplayed = false
            self.primaryButtonAction?()
        }) {
            HStack {
                if let primaryButtonIcon = primaryButtonIcon {
                    Image(uiImage: primaryButtonIcon)
                }
                Text(primaryButtonTitle)
            }
                .frame(minWidth: 0, maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.green)
                .foregroundColor(Color.white)
                .cornerRadius(25)
        }
    }
    
    // secondary button
    var secondaryButton: some View {
        Button(action: {
            self.isDisplayed = false
            self.secondaryButtonAction?()
        }) {
            Text(secondaryButtonTitle)
                .frame(minWidth: 0, maxWidth: .infinity)
                .frame(height: 40)
                .foregroundColor(Color.gray)
                .padding(.vertical, alertDescription.isEmpty ? 5.0 : 0.0)
                .overlay(alertDescription.isEmpty ?
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.gray, lineWidth: 1)
                    : nil)

        }
    }
    
    @Binding var alertTextFieldValue: String
    
    var alertTextField: some View {
        return TextField(alertTextFieldTitle, text: $alertTextFieldValue)
    }
    
    init(isDisplayed: Binding<Bool>,
         showCloseIcon: Bool = true,
         alertIcon: UIImage,
         alertTitle: String = "",
         alertDescription: String = "",
         primaryButtonIcon: UIImage? = nil,
         primaryButtonTitle: String = "",
         secondaryButtonTitle: String = "",
         primaryButtonAction: ButtonAction? = nil,
         secondaryButtonAction: ButtonAction? = nil,
         buttonStyle: ButtonStyle = .vertical,
         alertTextFieldTitle: String = "",
         alertTextFieldValue: Binding<String> = .constant(""),
         modelContentMode: ModelContentMode = .halfScreen) {
        self._isDisplayed = isDisplayed
        self.showCloseIcon = showCloseIcon
        self.alertIcon = alertIcon
        self.alertTitle = alertTitle
        self.alertDescription = alertDescription
        self.primaryButtonIcon = primaryButtonIcon
        self.primaryButtonTitle = primaryButtonTitle
        self.secondaryButtonTitle = secondaryButtonTitle
        self.primaryButtonAction = primaryButtonAction
        self.secondaryButtonAction = secondaryButtonAction
        self.buttonStyle = buttonStyle
        self.alertTextFieldTitle = alertTextFieldTitle
        self._alertTextFieldValue = alertTextFieldValue
        self.modelContentMode = modelContentMode
    }

    // MARK: Body

    var body: some View {
        VStack {
            if modelContentMode == .halfScreen {
                Spacer()
            }
            
            VStack(spacing: 32) {
                
                if modelContentMode == .fullScreen {
                    Spacer()
                }

                if showCloseIcon {
                    HStack {
                        Spacer()
                        Image(systemName: "multiply")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .padding()
                            .onTapGesture {
                                self.isDisplayed = false
                            }
                    }
                }
                
                Image(uiImage: alertIcon)
                    .resizable()
                    .frame(width: 100, height: 100)
                    .padding(.top, showCloseIcon ? 0.0 : 20.0)
                
                if !alertTitle.isEmpty {
                    Text(alertTitle)
                        .multilineTextAlignment(.center)
                        .font(.title)
                        .frame(width: 200)
                }
                
                if !alertDescription.isEmpty {
                    Text(alertDescription)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .foregroundColor(Color.gray)
                }
                
                if !alertTextFieldTitle.isEmpty {
                    self.alertTextField
                        .multilineTextAlignment(.center)
                        .padding([.horizontal], 20)
                    Divider()
                        .padding([.horizontal], 20)
                }
                
                if modelContentMode == .fullScreen {
                    Spacer()
                }
                
                if buttonStyle == ButtonStyle.vertical {
                    VStack {
                        self.primaryButton
                            .padding([.horizontal], 20)
                            .padding(.bottom, secondaryButtonTitle.isEmpty ? 20 : 0.0)
                        if !secondaryButtonTitle.isEmpty {
                            self.secondaryButton
                                .padding([.horizontal, .bottom], 20)
                        }
                    }
                } else {
                    HStack {
                        self.primaryButton
                        if !secondaryButtonTitle.isEmpty {
                            self.secondaryButton
                        }
                    }
                    .padding([.horizontal, .bottom], 20)
                }
            }
            .background(Color.white)
            .cornerRadius(16)
            .padding(.horizontal, 10)
        }
    }
}
