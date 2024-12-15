//
//  CreateChannelView.swift
//  Gathering
//
//  Created by dopamint on 11/6/24.
//

import SwiftUI

import ComposableArchitecture
import PhotosUI

struct CreateChannelView: View {
    @Perception.Bindable var store: StoreOf<CreateChannelFeature>
    
    var body: some View {
        WithPerceptionTracking {
            VStack {
                SheetHeaderView(title: "채널 생성")
                    .background(Design.white)
                ScrollView {
                    VStack(spacing: 24) {
                        VStack {
                            CustomPhotoPicker(
                                selectedImages: $store.selectedImage,
                                maxSelectedCount: 1
                            ) {
                                if let images = store.selectedImage, let image = images.last {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 200, height: 200)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .foregroundColor(Design.darkGray)
                                } else {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8)
                                            .foregroundStyle(Design.gray)
                                            .frame(width: 200, height: 200)
                                        
                                        Image(systemName: "camera")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 50, height: 50)
                                            .foregroundColor(Design.white)
                                    }
                                    
                                }
                            }
                            Button(action: {
                                store.send(.deleteImageButtonTapped)
                            }, label: {
                                Text("이미지 초기화")
                                    .font(Design.caption)
                                    .foregroundStyle(Design.darkGray)
                            })
                            .padding(5)
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
