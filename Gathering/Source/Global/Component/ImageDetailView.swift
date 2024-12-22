//
//  ImageDetailView.swift
//  Gathering
//
//  Created by 김성민 on 12/10/24.
//

import SwiftUI

struct ImageDetailView: View {
    let imageNames: [String]
    @Environment(\.dismiss) var dismiss
    
    @State private var currentIndex: Int = 0
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    
    init(imageNames: [String]) {
        self.imageNames = imageNames
    }
    
    var body: some View {
        ZStack {
            // 배경
            Color.black.opacity(0.9)
                .edgesIgnoringSafeArea(.all)
            
            // 이미지 페이저
            TabView(selection: $currentIndex) {
                ForEach(0..<imageNames.count, id: \.self) { index in
                    imageContent(for: imageNames[index])
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // 닫기 버튼
            closeButton
            
            // 페이지 인디케이터
            pageIndicator
        }
        .navigationBarHidden(true)
    }
    
    // 이미지 콘텐츠 뷰
    private func imageContent(for imageName: String) -> some View {
        GeometryReader { geometry in
            LoadedImageView(urlString: imageName, size: geometry.size.width)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .scaleEffect(scale)
                .offset(offset)
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            scale = max(1.0, value)
                        }
                        .onEnded { _ in
                            withAnimation {
                                scale = max(1.0, scale)
                            }
                        }
                )
        }
    }
    
    // 닫기 버튼 뷰
    private var closeButton: some View {
        VStack {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: Design.xmark)
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            Circle()
                                .fill(Color.black.opacity(0.5))
                        )
                }
                Spacer()
            }
            Spacer()
        }
        .padding()
    }
    
    // 페이지 인디케이터 뷰
    private var pageIndicator: some View {
        VStack {
            Spacer()
            HStack(spacing: 8) {
                ForEach(0..<imageNames.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentIndex ? Color.white : Color.gray.opacity(0.5))
                        .frame(width: 5, height: 5)
                }
            }
            .padding(.bottom, 20)
        }
    }
}
