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
    case explore = "둘러보기"
}

struct RootView: View {
    @Perception.Bindable var store: StoreOf<RootFeature>
    
    var body: some View {
        WithPerceptionTracking {
            TabView(selection: .init(
                get: { store.selectedTab },
                set: { store.send(.setTab($0)) }
            )) {
                HomeView(store: store.scope(state: \.home, action: \.home))
                    .tabItem {
                        Image(store.selectedTab == .home ? .homeActive : .homeInactive)
                        Text(TabInfo.home.rawValue)
                    }
                    .tag(TabInfo.home)
                
                DMView(store: store.scope(state: \.dm, action: \.dm))
                    .tabItem {
                        Image(store.selectedTab == .dm ? .messageActive : .messageInactive)
                        Text(TabInfo.dm.rawValue)
                    }
                    .tag(TabInfo.dm)
                
                // MARK: - 검색
                NavigationStack {
                    EmptyView()
                }
                .tabItem {
                    Image(store.selectedTab == .search ? .profileActive : .profileInactive)
                    Text(TabInfo.search.rawValue)
                }
                .tag(TabInfo.search)
                
                // MARK: - 둘러보기
                NavigationStack {
                    ExploreView(store: store.scope(state: \.explore, action: \.explore))
                }
                .tabItem {
                    Image(store.selectedTab == .explore ? .settingActive : .settingInactive)
                    Text(TabInfo.explore.rawValue)
                }
                .tag(TabInfo.explore)
            }
        }
    }
}
