//
//  ContinueEmailButton.swift
//  Gathering
//
//  Created by 김성민 on 11/6/24.
//

import SwiftUI

struct ContinueEmailButton: View {
    var body: some View {
        HStack {
            Image(.email)
                .resizable()
                .frame(width: 20, height: 20)
            Text("이메일로 계속하기")
        }
        .asRoundButton(foregroundColor: Design.white, backgroundColor: Design.mainSkyblue)
    }
}
