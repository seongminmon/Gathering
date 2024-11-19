//
//  AppleLoginButton.swift
//  Gathering
//
//  Created by 김성민 on 11/6/24.
//

import SwiftUI

struct AppleLoginButton: View {
    var body: some View {
        HStack {
            Image(.logoApple)
                .resizable()
                .frame(width: 20, height: 20)
            Text("APPLE로 계속하기")
        }
        .asButtonStyle(foregroundColor: Design.white, backgroundColor: Design.black)
    }
}
