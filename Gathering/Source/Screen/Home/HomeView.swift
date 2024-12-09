//
//  HomeView.swift
//  Gathering
//
//  Created by dopamint on 11/4/24.
//

import SwiftUI

import ComposableArchitecture

struct HomeView: View {
    // TODO: - 채널 생성 시 뷰 갱신 필요
    
    @Perception.Bindable var store: StoreOf<HomeFeature>
    
    var body: some View {
        WithPerceptionTracking {
            NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
                ZStack(alignment: .bottomTrailing) {
                    coverLayer
                    makeFloatingButton {
                        store.send(.floatingButtonTap)
                    }
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
                case .dmChatting(let store):
                    DMChattingView(store: store)
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
        
    }
    
    private func channelListView() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(store.channelList, id: \.id) { channel in
                HStack {
                    let unreadResponse = store.channelUnreads[channel]
                    
                    Image(unreadResponse == nil ? .thin : .hashTagthick)
                        .resizable()
                        .frame(width: 15, height: 15)
                    
                    Button {
                        store.send(.channelTap(channel))
                    } label: {
                        Text(channel.name)
                            .foregroundColor(
                                unreadResponse == nil ? Design.darkGray : Design.black
                            )
                            .font(unreadResponse == nil ? Design.body : Design.bodyBold)
                        Spacer()
                        if let count = unreadResponse {
                            Text("\(count)")
                                .badge()
                        }
                    }
                }
            }
        }
    }
    
    private func dmListView() -> some View {
        LazyVStack(alignment: .leading, spacing: 12) {
            ForEach(store.dmRoomList, id: \.id) { dmRoom in
                let unreadResponse = store.dmUnreads[dmRoom]
                HStack {
                    LoadedImageView(urlString: dmRoom.user.profileImage ?? "", size: 30)
                    
                    Button {
                        store.send(.dmTap(dmRoom))
                    } label: {
                        Text(dmRoom.user.nickname)
                            .foregroundStyle(
                                unreadResponse == 0 || unreadResponse == nil ?
                                Design.darkGray : Design.black
                            )
                            .font(
                                unreadResponse == 0 || unreadResponse == nil ?
                                Design.body : Design.bodyBold
                            )
                        Spacer()
                        if let count = unreadResponse {
                            Text("\(count)")
                                .badge()
                        }
                    }
                }
            }
            
            makeAddButton(text: "새 메시지 시작") {
                store.send(.startNewMessageTap)
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
