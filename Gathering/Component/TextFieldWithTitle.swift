//
//  TextFieldWithTitle.swift
//  Gathering
//
//  Created by 김성민 on 11/15/24.
//

import SwiftUI

struct TextFieldWithTitle: View {
    
    var title: String
    var placeholder: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(Design.title2)
            TextField(placeholder, text: $text)
                .font(Design.body)
                .textFieldStyle(.roundedBorder)
        }
    }
}
