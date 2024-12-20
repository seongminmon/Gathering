//
//  RoundButtonModifier.swift
//  Gathering
//
//  Created by 김성민 on 11/6/24.
//

import SwiftUI

extension View {
    func asRoundButton(foregroundColor: Color,
                       backgroundColor: Color
    ) -> some View {
        self
            .font(Design.title2)
            .foregroundStyle(foregroundColor)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
