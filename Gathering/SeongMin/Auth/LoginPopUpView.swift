//
//  LoginPopUpView.swift
//  Gathering
//
//  Created by 김성민 on 11/12/24.
//

import SwiftUI

import ComposableArchitecture

struct LoginPopUpView: View {
    
    @State private var isSignUpViewPresented = false
    
    var body: some View {
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
                print("이메일 로그인 버튼 탭")
            } label: {
                ContinueEmailButton()
            }
            Button {
                print("회원가입 버튼 탭")
                isSignUpViewPresented = true
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
        .sheet(isPresented: $isSignUpViewPresented) {
            SignUpView(
                store: Store(initialState: SignUpFeature.State()) { SignUpFeature() }
            )
                .presentationDragIndicator(.visible)
        }
    }
}
