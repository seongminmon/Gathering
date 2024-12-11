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
                SheetHeaderView(title: "채널 편집")
                    .background(Design.white)
                ScrollView {
                    VStack(spacing: 24) {
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
