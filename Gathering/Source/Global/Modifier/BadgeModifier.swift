//
//  BadgeModifier.swift
//  Gathering
//
//  Created by 김성민 on 11/19/24.
//

import SwiftUI

extension View {
    func badge(backgroundColor: Color = Design.mainSkyblue,
               textColor: Color = Design.white
    ) -> some View {
        self
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(backgroundColor)
            .foregroundStyle(textColor)
            .clipShape(Capsule())
    }
}
