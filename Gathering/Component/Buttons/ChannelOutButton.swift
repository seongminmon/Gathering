//
//  ChannelOutButton.swift
//  Gathering
//
//  Created by 김성민 on 11/6/24.
//

import SwiftUI

struct ChannelOutButton: View {
    var body: some View {
        Text("채널에서 나가기")
            .font(Design.title2)
            .foregroundStyle(Design.black)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(Design.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Design.black, lineWidth: 1)
            )
            .padding()
    }
}
