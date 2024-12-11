//
//  ToastView.swift
//  Gathering
//
//  Created by 김성민 on 11/12/24.
//

import SwiftUI

struct ToastView: View {
    var title: String
    
    var body: some View {
        Text(title)
            .font(Design.body)
            .padding(8)
            .foregroundStyle(Design.white)
            .background(Design.mainSkyblue)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
