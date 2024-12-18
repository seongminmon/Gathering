//
//  RootView.swift
//  Gathering
//
//  Created by 김성민 on 11/4/24.
//

import SwiftUI

import ComposableArchitecture

struct RootView: View {
    @Perception.Bindable var store: StoreOf<RootFeature>
    
    var body: some View {
        WithPerceptionTracking {
            TabView(selection: $store.selectedTab) {
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
