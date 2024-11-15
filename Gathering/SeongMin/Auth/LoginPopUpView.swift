//
//  LoginPopUpView.swift
//  Gathering
//
//  Created by 김성민 on 11/12/24.
//

import SwiftUI

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
            SignUpView()
                .presentationDragIndicator(.visible)
        }
    }
}

struct SignUpView: View {
    
    @State private var emailText = ""
    @State private var nicknameText = ""
    @State private var phoneText = ""
    @State private var passwordText = ""
    @State private var passwordCheckText = ""
    
    @State private var isValid = false
    
    var body: some View {
        VStack {
            SheetHeaderView(title: "회원가입")
            ScrollView {
                VStack(spacing: 24) {
                    TextFieldWithTitle(title: "이메일",
                                       placeholder: "이메일을 입력하세요",
                                       text: $emailText)
                    TextFieldWithTitle(title: "닉네임",
                                       placeholder: "닉네임을 입력하세요",
                                       text: $nicknameText)
                    TextFieldWithTitle(title: "연락처", 
                                       placeholder: "전화번호를 입력하세요",
                                       text: $phoneText)
                    TextFieldWithTitle(title: "비밀번호", 
                                       placeholder: "비밀번호를 입력하세요",
                                       text: $passwordText)
                    TextFieldWithTitle(title: "비밀번호 확인", 
                                       placeholder: "비밀번호를 한 번 더 입력하세요",
                                       text: $passwordCheckText)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .background(Design.gray)
             
        }
    }
    
    @ViewBuilder
    private func signUpButton() -> some View {
        if isValid {
            RoundedButton(text: "가입하기",
                          foregroundColor: Design.white,
                          backgroundColor: Design.green)
        } else {
            RoundedButton(text: "가입하기",
                          foregroundColor: Design.white,
                          backgroundColor: Design.darkGray)
        }
    }
}

struct TextFieldWithTitle: View {
    
    var title: String
    var placeholder: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(Design.title2)
            TextField(placeholder, text: $text)
                .font(Design.body)
                .textFieldStyle(.roundedBorder)
                
        }
    }
}
