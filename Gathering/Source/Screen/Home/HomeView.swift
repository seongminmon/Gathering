//
//  HomeView.swift
//  Gathering
//
//  Created by dopamint on 11/4/24.
//

import SwiftUI

import ComposableArchitecture

struct HomeView: View {
    @Perception.Bindable var store: StoreOf<HomeFeature>
    
    var body: some View {
        WithPerceptionTracking {
            NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
                ZStack(alignment: .bottomTrailing) {
                    coverLayer
                }
                .asGatheringNavigationModifier(
                    gatheringImage: store.currentWorkspace?.coverImage ?? "",
                    title: store.currentWorkspace?.name ?? "",
                    myProfile: store.myProfile
                )
                .confirmationDialog(
                    store: store.scope(
                        state: \.$confirmationDialog,
                        action: \.confirmationDialog
                    )
                )
                .task { store.send(.task) }
            } destination: { store in
                switch store.case {
                case .profile(let store):
                    ProfileView(store: store)
                case .channelChatting(let store):
                    ChannelChattingView(store: store)
                case .channelSetting(let store):
                    ChannelSettingView(store: store)
                }
            }
        }
    }
}

extension HomeView {
    private func scrollView() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                CustomDisclosureGroup(
                    label: "모임",
                    isExpanded: $store.isChannelExpanded
                ) {
                    channelGridView()
                    makeAddButton(text: "모임 추가") {
                        store.send(.addChannelButtonTap)
                    }
                }
                .padding()
            }
            .foregroundStyle(.black)
            Divider()
            makeAddButton(text: "팀원 추가") {
                store.send(.inviteMemberButtonTap)
            }
            .padding(EdgeInsets(top: 5, leading: 15, bottom: 0, trailing: 0))
        }
    }
    
    private func channelGridView() -> some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ],
            spacing: 16
        ) {
            ForEach(store.channelList, id: \.id) { channel in
                ChannelGridCell(
                    channel: channel,
                    unreadCount: store.channelUnreads[channel],
                    onTap: {
                        store.send(.channelTap(channel))
                    }
                )
            }
        }
        .padding(.horizontal, 8)
    }
    
    private struct ChannelGridCell: View {
        let channel: Channel
        let unreadCount: Int?
        let onTap: () -> Void
        
        var body: some View {
            Button(action: onTap) {
                GeometryReader { geometry in
                    VStack(spacing: 0) {
                        LoadedImageView(urlString: channel.coverImage ?? "placeholder",
                                        size: .infinity,
                                        isCoverImage: true)
                            .frame(maxWidth: .infinity)
                            .frame(height: geometry.size.height * 0.65)
                            .clipped()
                        
                        HStack {
                            Text(channel.name)
                                .foregroundStyle(
                                    unreadCount == 0 || unreadCount == nil ?
                                    Design.darkGray : Design.black
                                )
                                .font(unreadCount == 0 || unreadCount == nil ?
                                      Design.body : Design.bodyBold)
                                .lineLimit(1)
                                .multilineTextAlignment(.leading)

                                .background(Design.chatBackground)
                                .padding(.horizontal, 8)
                            Spacer()
                            
                            if let count = unreadCount {
                                Text("\(count)")
                                    .badge()
                                    .opacity(count <= 0 ? 0 : 1)
                            }
                        }
                        .padding(6)
                    }
                    .background(Design.chatBackground)
                    .cornerRadius(8)
                    .shadow(color: .black.opacity(0.1), radius: 2)
                }
                .aspectRatio(1, contentMode: .fit)
            }
        }
    }
    
    private func makeAddButton(text: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(.plus)
                    .resizable()
                    .frame(width: 15, height: 15)
                Text(text)
                    .font(.body)
                Spacer()
            }
            .padding(.top)
            .foregroundStyle(Design.darkGray)
        }
    }
    
    private func makeFloatingButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "square.and.pencil")
                .foregroundStyle(Design.white)
                .font(.system(size: 25))
                .frame(width: 60, height: 60)
                .background(Design.mainSkyblue)
                .clipShape(Circle())
                .shadow(radius: 4)
        }
        .padding(.trailing, 16)
        .padding(.bottom, 16)
    }
}

extension HomeView {
    var navigationLayer: some View {
        scrollView()
    }
    
    var sheetLayer: some View {
        navigationLayer
            .sheet(
                item: $store.scope(
                    state: \.destination?.channelAdd,
                    action: \.destination.channelAdd
                )
            ) { store in
                CreateChannelView(store: store)
            }
            .sheet(
                item: $store.scope(
                    state: \.destination?.inviteMember,
                    action: \.destination.inviteMember
                )
            ) { store in
                InviteMemberView(store: store)
            }
    }
    
    var coverLayer: some View {
        sheetLayer
            .fullScreenCover(
                item: $store.scope(
                    state: \.destination?.channelExplore,
                    action: \.destination.channelExplore
                )
            ) { store in
                ExploreChannelView(store: store)
            }
    }
}
