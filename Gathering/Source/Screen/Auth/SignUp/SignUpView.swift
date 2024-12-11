//
//  SignUpView.swift
//  Gathering
//
//  Created by 김성민 on 11/15/24.
//

import SwiftUI

import ComposableArchitecture

struct SignUpView: View {
    
    @Perception.Bindable var store: StoreOf<SignUpFeature>
    
    var body: some View {
        WithPerceptionTracking {
            VStack {
                SheetHeaderView(title: "회원가입")
                    .background(Design.white)
                ScrollView {
                    VStack(spacing: 24) {
                        TextFieldWithTitle(title: "이메일",
                                           placeholder: "이메일을 입력하세요",
                                           text: $store.emailText)
                        TextFieldWithTitle(title: "닉네임",
                                           placeholder: "닉네임을 입력하세요",
                                           text: $store.nicknameText)
                        TextFieldWithTitle(title: "연락처",
                                           placeholder: "전화번호를 입력하세요",
                                           text: $store.phoneText)
                        .keyboardType(.phonePad)
                        .onChange(of: store.phoneText) { newValue in
                            store.send(.phoneTextChange(newValue))
                        }
                        
                        SecureTextFieldWithTitle(title: "비밀번호",
                                           placeholder: "비밀번호를 입력하세요",
                                           text: $store.passwordText)
                        SecureTextFieldWithTitle(title: "비밀번호 확인",
                                           placeholder: "비밀번호를 한 번 더 입력하세요",
                                           text: $store.passwordCheckText)
                    }
                    .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                signUpButton()
                    .padding([.horizontal, .bottom])
            }
            .background(Design.background)
        }
    }
    
    @ViewBuilder
    private func signUpButton() -> some View {
        if store.isButtonValid {
            Button {
                store.send(.signUpButtonTap)
            } label: {
                RoundedButton(text: "가입하기",
                              foregroundColor: Design.white,
                              backgroundColor: Design.mainSkyblue)
            }
        } else {
            RoundedButton(text: "가입하기",
                          foregroundColor: Design.white,
                          backgroundColor: Design.darkGray)
        }
    }
}
