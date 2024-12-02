//
//  ChannelExploreView.swift
//  Gathering
//
//  Created by dopamint on 11/8/24.
//

import SwiftUI

import ComposableArchitecture

struct ExploreChannelView: View {
    @Perception.Bindable var store: StoreOf<ExploreChannelFeature>
    
    var body: some View {
        WithPerceptionTracking {
            ZStack {
                VStack(spacing: 0) {
                    SheetHeaderView(title: "채널 탐색")
                    makeScrollView()
                }
                .customAlert(
                    isPresented: $store.showAlert,
                    title: "채널 참여",
                    message: "[\(store.selectedChannel?.name ?? "")] 채널에 참여 하시겠습니까?",
                    primaryButton: .init(
                        title: "확인",
                        action: {
                            store.send(.confirmJoinChannel(store.selectedChannel))
                        }
                    ),
                    secondaryButton: .init(
                        title: "취소",
                        action: {
                            store.send(.cancelJoinChannel)
                        }
                    )
                )
            }
        }
    }
    private func makeScrollView() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(store.allChannels, id: \.id) { channel in
                    Button {
                        store.send(.channelTap(channel))
                    } label: {
                        HStack(spacing: 12) {
                            Image(.hashTagthick)
                            Text(channel.name)
                                .font(Design.title2)
                                .tint(Design.black)
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            .padding(.vertical, 20)
        }
        .task { store.send(.task) }
    }
}
