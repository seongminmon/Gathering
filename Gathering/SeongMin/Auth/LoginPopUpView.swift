//
//  LoginPopUpView.swift
//  Gathering
//
//  Created by 김성민 on 11/12/24.
//

import SwiftUI

struct LoginPopUpView: View {
    var body: some View {
        VStack(spacing: 16) {
            AppleLoginButton()
            KakaoLoginButton()
            ContinueEmailButton()
            Button {
                print("회원가입 버튼 탭")
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
    }
}
