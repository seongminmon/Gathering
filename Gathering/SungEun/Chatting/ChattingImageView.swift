//
//  ChattingImageView.swift
//  Gathering
//
//  Created by 여성은 on 11/8/24.
//

import SwiftUI

struct ChattingImageView: View {
    var imageName: String
    var body: some View {
        Image(imageName)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 240, height: 160)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}


