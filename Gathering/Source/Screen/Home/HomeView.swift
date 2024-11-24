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
            GatheringNavigationStack(gatheringImage: store.currentWorkspace?.coverImage ?? "",
                                     title: store.currentWorkspace?.name ?? "",
                                     myprofileData: store.myProfile) {
                ZStack(alignment: .bottomTrailing) {
                    coverLayer
                    makeFloatingButton {
                        store.send(.floatingButtonTap)
                    }
                }
                .confirmationDialog(
                    store: self.store.scope(
                        state: \.$confirmationDialog,
                        action: \.confirmationDialog
                    )
                )
            }
            
        }
    }
}

extension HomeView {
    
    private func scrollView() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                CustomDisclosureGroup(
                    label: "채널",
                    isExpanded: $store.isChannelExpanded
                ) {
                    channelListView()
                    makeAddButton(text: "채널 추가") {
                        store.send(.addChannelButtonTap)
                    }
                }
                .padding()
                Divider()
                
                CustomDisclosureGroup(
                    label: "다이렉트 메시지",
                    isExpanded: $store.isDMExpanded
                ) {
                    dmListView()
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
        .task { store.send(.task) }
    }
    
    private func channelListView() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(store.channels, id: \.id) { channel in
                HStack {
                    Image(channel.unreadCount == nil ? .thin : .hashTagthick)
                        .resizable()
                        .frame(width: 15, height: 15)
                    
                    Button {
                        store.send(.channelTap(channel))
                    } label: {
                        Text(channel.name)
                            .foregroundColor(
                                channel.unreadCount == nil ? Design.darkGray : Design.black
                            )
                            .font(channel.unreadCount == nil ? Design.body : Design.bodyBold)
                        Spacer()
                        if let count = channel.unreadCount {
                            Text("\(count)")
                                .badge()
                        }
                    }
                }
            }
        }
    }
    
    private func dmListView() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(store.users) { user in
                HStack {
                    ProfileImageView(urlString: user.profileImage, size: 30)
                    Button {
                        store.send(.dmTap(user))
                    } label: {
                        Text(user.name)
                            .foregroundColor(
                                user.unreadCount == nil ? Design.darkGray : Design.black
                            )
                            .font(user.unreadCount == nil ? Design.body : Design.bodyBold)
                        Spacer()
                        if let count = user.unreadCount {
                            Text("\(count)")
                                .badge()
                        }
                    }
                }
            }
            makeAddButton(text: "새 메시지 시작") {
                //                store.send(.startNewMessageTap)
            }
        }
    }
    
    private func makeAddButton(text: String,
                               action: @escaping () -> Void) -> some View {
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
            .foregroundColor(Design.darkGray)
        }
    }
    
    private func makeFloatingButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Button(action: action) {
                Image(systemName: "square.and.pencil")
                    .foregroundColor(Design.white)
                    .font(.system(size: 25))
                    .frame(width: 60, height: 60)
                    .background(Design.green)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
            .padding(.trailing, 16)
            .padding(.bottom, 16)
        }
    }
}

extension HomeView {
    var navigationLayer: some View {
        scrollView()
            .navigationDestination(
                item: $store.scope(
                    state: \.destination?.channelChatting,
                    action: \.destination.channelChatting
                )
            ) { store in
                ChannelChattingView(store: store)
            }
            .navigationDestination(
                item: $store.scope(
                    state: \.destination?.DMChatting,
                    action: \.destination.DMChatting
                )
            ) { store in
                DMChattingView(store: store)
            }
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
                ChannelExploreView(store: store)
            }
    }
}
