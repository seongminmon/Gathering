//
//  View+.swift
//  Gathering
//
//  Created by 김성민 on 11/6/24.
//

import SwiftUI

extension View {
    func asButtonStyle(foregroundColor: Color, backgroundColor: Color) -> some View {
        self
            .font(Design.title2)
            .foregroundStyle(foregroundColor)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding()
    }
    
    func badge(
        backgroundColor: Color = Design.green,
        textColor: Color = Design.white
    ) -> some View {
        self
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(backgroundColor)
            .foregroundColor(textColor)
            .clipShape(Capsule())
    }
}
