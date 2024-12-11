//
//  EmailLoginView.swift
//  Gathering
//
//  Created by 김성민 on 11/16/24.
//

import SwiftUI

import ComposableArchitecture

struct EmailLoginView: View {
    
    @Perception.Bindable var store: StoreOf<EmailLoginFeature>
    
    var body: some View {
        WithPerceptionTracking {
            VStack {
                SheetHeaderView(title: "이메일 로그인")
                    .background(Design.white)
                ScrollView {
                    VStack(spacing: 24) {
                        TextFieldWithTitle(title: "이메일",
                                           placeholder: "이메일을 입력하세요",
                                           text: $store.emailText)
                        
                        SecureTextFieldWithTitle(title: "비밀번호",
                                           placeholder: "비밀번호를 입력하세요",
                                           text: $store.passwordText)
                        
                        HStack(spacing: 20) {
                            Button("성은") {
                                store.send(.test1ButtonTap)
                            }
                            Button("성민") {
                                store.send(.test2ButtonTap)
                            }
                            Button("승현") {
                                store.send(.test3ButtonTap)
                            }
                        }
                    }
                    .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                logInButton()
                    .padding([.horizontal, .bottom])
            }
            .background(Design.background)
        }
    }
    
    @ViewBuilder
    private func logInButton() -> some View {
        if store.isButtonValid {
            Button {
                store.send(.logInButtonTap)
            } label: {
                RoundedButton(text: "로그인",
                              foregroundColor: Design.white,
                              backgroundColor: Design.mainSkyblue)
            }
        } else {
            RoundedButton(text: "로그인",
                          foregroundColor: Design.white,
                          backgroundColor: Design.darkGray)
        }
    }
}
