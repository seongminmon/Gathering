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
            .onChange(of: urlString) { newValue in
                // URL이 변경될 때마다 이미지를 새로 로드
                Task {
                    do {
                        let result = try await NetworkManager.shared.requestImage(
                            ImageRouter.fetchImage(path: newValue)
                        )
                        uiImage = result
                    } catch {}
                }
            }
            .task {
                // 초기 로드
                guard !urlString.isEmpty else { return }
                do {
                    let result = try await NetworkManager.shared.requestImage(
                        ImageRouter.fetchImage(path: urlString)
                    )
                    uiImage = result
                } catch {}
            }
    }
    
    @ViewBuilder
    private func imageView() -> some View {
        if let uiImage {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: size * 0.2))
                .shadow(color: Design.black.opacity(0.1), radius: 2, x: 0, y: 1)
        } else {
            Image("bird")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: size * 0.2))
                .shadow(color: Design.black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
    }
}
