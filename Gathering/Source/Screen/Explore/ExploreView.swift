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
                VStack(spacing: 0) {
                    // 검색창 추가
                    searchBar
                    
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            // filteredChannels로 변경
                            ForEach(store.filteredChannels, id: \.id) { channel in
                                channelCell(channel)
                            }
                        }
                    }
                }
                .asGatheringNavigationModifier(
                    gatheringImage: store.currentWorkspace?.coverImage ?? "",
                    title: "모임 둘러보기",
                    myProfile: store.myProfile
                )
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
            .onAppear { store.send(.onAppear) }
            
//            .customAlert(
//                isPresented: $store.showAlert,
//                title: "채널 참여",
//                message: "[\(store.selectedChannel?.name ?? "")] 채널에 참여 하시겠습니까?",
//                primaryButton: .init(
//                    title: "확인",
//                    action: {
//                        store.send(.confirmJoinChannel(store.selectedChannel))
//                    }
//                ),
//                secondaryButton: .init(
//                    title: "취소",
//                    action: {
//                        store.send(.cancelJoinChannel)
//                    }
//                )
//            )
        }
    }
    private var searchBar: some View {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Design.textGray)
                
                TextField("채널 검색", text: $store.searchText)
                    .textFieldStyle(.plain)
                
                if !store.searchText.isEmpty {
                    Button {
                        store.searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Design.textGray)
                    }
                }
            }
            .padding(8)
            .background(Design.background)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    
    private func channelCell(_ channel: Channel) -> some View {
        Button {
            store.send(.channelCellTap(channel))
        } label: {
            HStack(spacing: 8) {
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
                
                Spacer()
                let flag = store.myChannels.contains(channel)
                Text(flag ? "참여 중" : "참여하기")
                    .font(Design.bodyBold)
                    .foregroundStyle(Design.white)
                    .padding(8)
                    .background(flag ? Design.gray : Design.mainSkyblue)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            Spacer()
        }
        .background(Design.background)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal, 16)
    }
}
