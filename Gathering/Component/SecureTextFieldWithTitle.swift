//
//  SecureTextFieldWithTitle.swift
//  Gathering
//
//  Created by 김성민 on 11/16/24.
//

import SwiftUI

struct SecureTextFieldWithTitle: View {
    
    var title: String
    var placeholder: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(Design.title2)
            SecureField(placeholder, text: $text)
                .font(Design.body)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
        }
    }
}
