//
//  ChannelExploreView.swift
//  Gathering
//
//  Created by dopamint on 11/8/24.
//

import SwiftUI

import ComposableArchitecture

struct ChannelExploreView: View {
    @Perception.Bindable var store: StoreOf<ChannelExploreFeature>
    
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
                            store.send(.confirmJoinChannel)
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
                ForEach(store.channels, id: \.id) { channel in
                    HStack(spacing: 12) {
                        Image("hashTagthick")
                        
                        Button(action: {
                            store.send(.channelTap(channel))
                        }) {
                            Text(channel.name)
                                .font(Design.title2)
                                .tint(Design.black)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                }
            }
            .padding(.vertical, 20)
        }
    }
        
}
