//
//  ExploreView.swift
//  Gathering
//
//  Created by dopamint on 11/20/24.
//

import SwiftUI

import ComposableArchitecture

struct ExploreView: View {
    
    @Perception.Bindable var store: StoreOf<ExploreFeature>
    
    var body: some View {
        WithPerceptionTracking {
            NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(store.channelList, id: \.channel_id) { channel in
                            channelCell(channel)
                        }
                    }
                }
            } destination: { store in
                switch store.case {
                case .channelChatting(let store):
                    ChannelChattingView(store: store)
                case .channelSetting(let store):
                    ChannelSettingView(store: store)
                case .profile(let store):
                    ProfileView(store: store)
                }
            }
        }
    }
    
    private func channelCell(_ channel: ChannelResponse) -> some View {
        Button {
            print("채널 셀 탭")
        } label: {
            HStack(alignment: .top, spacing: 8) {
                LoadedImageView(urlString: channel.coverImage ?? "", size: 80)
                    .padding(8)
                VStack(alignment: .leading, spacing: 4) {
                    Text(channel.name)
                        .font(Design.bodyBold)
                    Text(channel.description ?? "")
                        .font(Design.body)
                    Spacer()
                    
                    HStack(spacing: 4) {
                        // TODO: - 채널 주인 프로필 사진 + 닉네임으로 변경
                        LoadedImageView(urlString: "", size: 32)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Design.mainSkyblue, lineWidth: 2))
                        Text("야호")
                        Image(systemName: Design.person2)
                        Text("\(channel.channelMembers?.count ?? 0)명 참여")
                            .font(Design.body)
                    }
                    .font(Design.body)
                    .foregroundStyle(Design.textGray)
                }
                .foregroundStyle(Design.black)
                .lineLimit(1)
                .padding(.vertical, 4)
            }
            Spacer()
        }
        .background(Design.background)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal, 16)
    }
}
