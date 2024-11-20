//
//  ProfileImageView.swift
//  Gathering
//
//  Created by dopamint on 11/5/24.
//

import SwiftUI

struct ProfileImageView: View {
    var urlString: String
    var size: CGFloat
    
    @State var uiImage: UIImage?
    
    var body: some View {
        imageView()
            .task {
                do {
                    let result = try await NetworkManager.shared.requestImage(
                        ImageRouter.fetchImage(path: urlString)
                    )
                    uiImage = result
                } catch {
                    print("이미지 로드 실패")
                }
            }
    }
    
    @ViewBuilder
    private func imageView() -> some View {
        if let uiImage {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: size * 0.2))
                .shadow(color: Design.black.opacity(0.1), radius: 2, x: 0, y: 1)
        } else {
            Image("bird")
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: size * 0.2))
                .shadow(color: Design.black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
    }
}
