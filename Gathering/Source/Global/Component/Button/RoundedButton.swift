//
//  RoundedButton.swift
//  Gathering
//
//  Created by 김성민 on 11/6/24.
//

import SwiftUI

struct RoundedButton: View {
    var text: String
    var foregroundColor: Color
    var backgroundColor: Color
    
    var body: some View {
        Text(text)
            .asButtonStyle(foregroundColor: foregroundColor, backgroundColor: backgroundColor)
    }
}
