//
//  CustomAlert.swift
//  Gathering
//
//  Created by dopamint on 11/13/24.
//

import SwiftUI

struct CustomAlert: View {
    @Binding var isPresented: Bool
    let title: String
    let message: String
    var primaryButton: AlertButton
    var secondaryButton: AlertButton?
    
    @State private var opacity: Double = 0
    
    struct AlertButton {
        let title: String
        let action: () -> Void
        
        static func defaultPrimary(isPresented: Binding<Bool>) -> AlertButton {
            AlertButton(title: "확인") {
                isPresented.wrappedValue = false
            }
        }
    }
    
    init(
        isPresented: Binding<Bool>,
        title: String,
        message: String,
        primaryButton: AlertButton? = nil,
        secondaryButton: AlertButton? = nil
    ) {
        self._isPresented = isPresented
        self.title = title
        self.message = message
        self.primaryButton = primaryButton ?? .defaultPrimary(isPresented: isPresented)
        self.secondaryButton = secondaryButton
    }
    
    var body: some View {
        ZStack {
            // 배경
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 제목
                Text(title)
                    .font(Design.title2)
                    .padding(.top, 24)
                    .padding(.bottom, 8)
                
                // 메시지
                Text(message)
                    .font(Design.body)
                    .foregroundColor(Design.textGray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                
                // 버튼 영역
                HStack(spacing: 8) {
                    if let secondaryButton = secondaryButton {
                        Button {
                            withAnimation(.easeOut(duration: 0.2)) {
                                opacity = 0
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                secondaryButton.action()
                            }
                        } label: {
                            Text(secondaryButton.title)
                                .asRoundButton(
                                    foregroundColor: Design.black,
                                    backgroundColor: Design.gray
                                )
                        }
                    }
                    
                    Button {
                        withAnimation(.easeOut(duration: 0.2)) {
                            opacity = 0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            primaryButton.action()
                        }
                    } label: {
                        Text(primaryButton.title)
                            .asRoundButton(foregroundColor: Design.white,
                                           backgroundColor: Design.mainSkyblue)
                    }
                    
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Design.white)
            )
            .padding(.horizontal, 40)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.2)) {
                opacity = 1
            }
        }
    }
}

extension View {
    func customAlert(isPresented: Binding<Bool>,
                     title: String,
                     message: String,
                     primaryButton: CustomAlert.AlertButton? = nil,
                     secondaryButton: CustomAlert.AlertButton? = nil
    ) -> some View {
        ZStack {
            self
            
            if isPresented.wrappedValue {
                CustomAlert(
                    isPresented: isPresented,
                    title: title,
                    message: message,
                    primaryButton: primaryButton,
                    secondaryButton: secondaryButton
                )
                .transition(.opacity)
            }
        }
    }
}
