//
//  CreateChannelView.swift
//  Gathering
//
//  Created by dopamint on 11/6/24.
//

import SwiftUI

import ComposableArchitecture

struct CreateChannelView: View {
    @Perception.Bindable var store: StoreOf<CreateChannelFeature>
    
    var body: some View {
        WithPerceptionTracking {
            VStack {
                SheetHeaderView(title: "채널 생성")
                    .background(Design.white)
                ScrollView {
                    VStack(spacing: 24) {
                        CustomPhotoPicker(
                            selectedImages: $store.selectedImage,
                            maxSelectedCount: 1
                        ) {
                            if let images = store.selectedImage, let image = images.last {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200, height: 200)
                                    .cornerRadius(10)
                            } else {
                                Image(systemName: "camera")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200, height: 200)
                                    .cornerRadius(10)
                                
                            }
                        }
                        if let images = store.testImage, let image = images.last {
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: 100, height: 100)
                                .cornerRadius(10)
                        }
                        
                        TextFieldWithTitle(
                            title: "채널 이름",
                            placeholder: "채널 이름을 입력해주세요",
                            text: $store.channelName
                        )
                        TextFieldWithTitle(
                            title: "채널 설명",
                            placeholder: "채널 설명을 입력해주세요",
                            text: $store.channelDescription
                        )
                    }
                    .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Button {
                    store.send(.saveButtonTapped)
                } label: {
                    RoundedButton(
                        text: "생성",
                        foregroundColor: Design.white,
                        backgroundColor: store.isValid ? Design.mainSkyblue : Design.darkGray
                    )
                }
                .disabled(!store.isValid)
                .padding([.horizontal, .bottom])
            }
            .background(Design.background)
        }
    }
}
