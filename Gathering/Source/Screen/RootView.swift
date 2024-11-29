//
//  RootView.swift
//  Gathering
//
//  Created by 김성민 on 11/4/24.
//

import SwiftUI

import ComposableArchitecture

enum TabInfo : String, CaseIterable {
    case home = "홈"
    case dm = "DM"
    case search = "검색"
    case setting = "설정"
}

struct RootView: View {
    @Perception.Bindable var store: StoreOf<RootFeature>
    
    var body: some View {
        WithPerceptionTracking {
            TabView(selection: .init(
                get: { store.selectedTab },
                set: { store.send(.setTab($0)) }
            )) {
                GatheringNavigationStack(
                    gatheringImage: store.home.currentWorkspace?.coverImage ?? "",
                    title: store.home.currentWorkspace?.name ?? "",
                    myProfile: store.home.myProfile
                ) {
                    HomeView(store: store.scope(
                        state: \.home,
                        action: \.home
                    ))
                }
                .tabItem {
                    Image(store.selectedTab == .home ? .homeActive : .homeInactive)
                    Text(TabInfo.home.rawValue)
                }
                .tag(TabInfo.home)
                
                GatheringNavigationStack(
                    gatheringImage: store.dm.currentWorkspace?.coverImage ?? "",
                    title: "Direct Message",
                    myProfile: store.dm.myProfile
                ) {
                    DMView(store: store.scope(
                        state: \.dm,
                        action: \.dm
                    ))
                }
                .tabItem {
                    Image(store.selectedTab == .dm ? .messageActive : .messageInactive)
                    Text(TabInfo.dm.rawValue)
                }
                .tag(TabInfo.dm)
                
                // MARK: - 검색
                NavigationStack {
                    ChannelSettingView(
                        store: Store(initialState: ChannelSettingFeature.State()) {
                            ChannelSettingFeature()
                        }
                    )
//                    ChannelChattingView(
//                        store: Store(initialState: ChannelChattingFeature.State(channelID: "f755a2b0-547a-4215-8f72-af1be294ce09", workspaceID: "4e31f58f-aedd-4b3a-a4cb-b7597fafe8d2"),
//                                     reducer: {
//                                         ChannelChattingFeature()
//                                     })
//                    )
                }
                .tabItem {
                    Image(store.selectedTab == .search ? .profileActive : .profileInactive)
                    Text(TabInfo.search.rawValue)
                }
                .tag(TabInfo.search)
                
                // MARK: - 설정
                NavigationStack {
                    DMChattingView(
                        store: Store(initialState: DMChattingFeature.State(
                            dmsRoomResponse: DMsRoom(id: "3b2d5ad1-4843-4a97-8740-ea725092671f",
                                                     createdAt: "2024-11-19T07:06:42.463Z",
                                                     user: Member(
                                                        id: "87b8dfe8-ed7c-4927-b2dd-9daac283758a",
                                                        email: "qqq@yes.com",
                                                        nickname: "새싹",
                                                        profileImage: nil))),
                                     reducer: {
                                         DMChattingFeature()
                                     })
                    )
                }
                .tabItem {
                    Image(store.selectedTab == .setting ? .settingActive : .settingInactive)
                    Text(TabInfo.setting.rawValue)
                }
                .tag(TabInfo.setting)
                
            }
        }
    }
}
