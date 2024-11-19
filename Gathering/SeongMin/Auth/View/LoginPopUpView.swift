//
//  LoginPopUpView.swift
//  Gathering
//
//  Created by 김성민 on 11/12/24.
//

import SwiftUI

import ComposableArchitecture

struct LoginPopUpView: View {
    
    @Perception.Bindable var store: StoreOf<LoginPopUpFeature>
    
    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 16) {
                Button {
                    print("애플 로그인 버튼 탭")
                } label: {
                    AppleLoginButton()
                }
                Button {
                    print("카카오 로그인 버튼 탭")
                } label: {
                    KakaoLoginButton()
                }
                Button {
                    store.send(.emailLoginButtonTap)
                } label: {
                    ContinueEmailButton()
                }
                Button {
                    store.send(.signUpButtonTap)
                } label: {
                    HStack {
                        Text("또는")
                            .foregroundStyle(Design.black)
                        Text("새롭게 회원가입 하기")
                            .foregroundStyle(Design.green)
                    }
                    .font(Design.title2)
                }
            }
            .padding(20)
            // 이메일 로그인 뷰
            .sheet(isPresented: $store.isEmailLoginViewPresented) {
                EmailLoginView(
                    store: store.scope(state: \.emailLogin, action: \.emailLogin)
                )
                .presentationDragIndicator(.visible)
            }
            // 회원 가입 뷰
            .sheet(isPresented: $store.isSignUpViewPresented) {
                SignUpView(
                    store: store.scope(state: \.signUp, action: \.signUp)
                )
                .presentationDragIndicator(.visible)
            }
        }
    }
}
