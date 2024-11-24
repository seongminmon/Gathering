//
//  ChannelOutButton.swift
//  Gathering
//
//  Created by 김성민 on 11/6/24.
//

import SwiftUI

struct RoundedBorderButton: View {
    var text: String
    var textColor: Color
    var borderColor: Color
    
    var body: some View {
        Text(text)
            .font(Design.title2)
            .foregroundStyle(textColor)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(Design.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(borderColor, lineWidth: 1)
            )
    }
}
