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
    
    @State private var tabInfo: TabInfo = .home
    
    var body: some View {
        tabView()
            .tint(.green)
    }
    
    private func tabView() -> some View {
        TabView(selection: $tabInfo) {
            // MARK: - 홈
//            GatheringNavigationStack(gatheringImage: "bird2",title: "짹사모", profileImage: "bird3") {
                HomeView(store: Store(initialState: HomeFeature.State()) {
                    HomeFeature()
                })
//            }
            .tabItem {
                Image(tabInfo == .home ? .homeActive : .homeInactive)
                Text(TabInfo.home.rawValue)
            }
            .tag(TabInfo.home)
            
            // MARK: - DM
//            NavigationStack {
                DMView(store: Store(initialState: DMFeature.State()) {
                    DMFeature()
                })
//            }
            .tabItem {
                Image(tabInfo == .dm ? .messageActive : .messageInactive)
                Text(TabInfo.dm.rawValue)
            }
            .tag(TabInfo.dm)
            
            // MARK: - 검색
            NavigationStack {
//                ChannelChattingView(
//                    store: Store(initialState: ChannelChattingFeature.State(channelID: "f755a2b0-547a-4215-8f72-af1be294ce09", workspaceID: "4e31f58f-aedd-4b3a-a4cb-b7597fafe8d2"),
//                                                 reducer: {
//                    ChannelChattingFeature()
//                })
//                )
                ChannelSettingView(store: Store(initialState: ChannelSettingFeature.State()) {
                    ChannelSettingFeature()
                })
            }
            .tabItem {
                Image(tabInfo == .search ? .profileActive : .profileInactive)
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
                Image(tabInfo == .setting ? .settingActive : .settingInactive)
                Text(TabInfo.setting.rawValue)
            }
            .tag(TabInfo.setting)
            
        }
    }
}
