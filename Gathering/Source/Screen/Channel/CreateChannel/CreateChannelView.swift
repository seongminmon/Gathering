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
                SheetHeaderView(title: "모임 생성")
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
                                        .frame(
                                            width: getScreenWidth()*0.5,
                                            height: getScreenWidth()*0.5
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .foregroundStyle(Design.darkGray)
                                } else {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8)
                                            .foregroundStyle(Design.gray)
                                            .frame(
                                                width: getScreenWidth()*0.5,
                                                height: getScreenWidth()*0.5
                                            )
                                        
                                        Image(systemName: "camera")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(
                                                width: getScreenWidth()*0.1,
                                                height: getScreenWidth()*0.1
                                            )
                                            .foregroundStyle(Design.white)
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
                            title: "모임 이름",
                            placeholder: "모임 이름을 입력해주세요",
                            text: $store.channelName
                        )
                        TextFieldWithTitle(
                            title: "모임 설명",
                            placeholder: "모임 설명을 입력해주세요",
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
