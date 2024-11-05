//
//  ProfileImageView.swift
//  Gathering
//
//  Created by dopamint on 11/5/24.
//

import SwiftUI

struct RoundedIconImageView: View {
    let imageName: String
    var size: CGFloat = 40
    
    var body: some View {
        Image(imageName)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: size * 0.2))
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}
