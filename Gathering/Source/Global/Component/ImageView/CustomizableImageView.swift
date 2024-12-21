//
//  CustomizableImageView.swift
//  Gathering
//
//  Created by 여성은 on 12/8/24.
//

import SwiftUI

struct CustomizableImageView: View {
    var urlString: String
    var width: CGFloat
    var height: CGFloat
    var cornerRadius: CGFloat
    
    @State var uiImage: UIImage?
    
    var body: some View {
        imageView()
            .onChange(of: urlString) { newValue in
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
                .aspectRatio(contentMode: .fill)
                .frame(width: width, height: height)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        } else {
            Image("placeholder")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: width, height: height)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
    }
}
