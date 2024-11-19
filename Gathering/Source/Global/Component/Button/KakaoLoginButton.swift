//
//  KakaoLoginButton.swift
//  Gathering
//
//  Created by 김성민 on 11/6/24.
//

import SwiftUI

struct KakaoLoginButton: View {
    var body: some View {
        HStack {
            Image(.logoKakao)
                .resizable()
                .frame(width: 20, height: 20)
            Text("카카오톡으로 계속하기")
        }
        .asRoundButton(foregroundColor: Design.black, backgroundColor: .yellow)
    }
}
