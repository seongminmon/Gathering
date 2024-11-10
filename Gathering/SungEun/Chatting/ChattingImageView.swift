//
//  ChattingImageView.swift
//  Gathering
//
//  Created by 여성은 on 11/8/24.
//

import SwiftUI

struct ChattingImageView: View {
    var imageNames: [String]
    var body: some View {
        HStack {
            Image(imageNames[0])
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipShape(RoundedRectangle(cornerRadius: 4))
        }
        .frame(width: 240, height: 160)
        .background(.blue)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
