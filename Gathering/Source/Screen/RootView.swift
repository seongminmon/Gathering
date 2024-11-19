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
    }
    
    private func tabView() -> some View {
        TabView(selection: $tabInfo) {
            // MARK: - 홈
            GatheringNavigationStack(gatheringImage: "bird2",title: "짹사모", profileImage: "bird3") {
                HomeView(store: Store(initialState: HomeFeature.State()) {
                    HomeFeature()
                })
            }
            .tabItem {
                Image(tabInfo == .home ? .homeActive : .homeInactive)
                Text(TabInfo.home.rawValue)
            }
            .tag(TabInfo.home)
            
            // MARK: - DM
            NavigationStack {
                DMView(store: Store(initialState: DMFeature.State()) {
                    DMFeature()
                })
            }
            .tabItem {
                Image(tabInfo == .dm ? .messageActive : .messageInactive)
                Text(TabInfo.dm.rawValue)
            }
            .tag(TabInfo.dm)
            
            // MARK: - 검색
            NavigationStack {
                ChattingView()
            }
            .tabItem {
                Image(tabInfo == .search ? .profileActive : .profileInactive)
                Text(TabInfo.search.rawValue)
            }
            .tag(TabInfo.search)
            
            // MARK: - 설정
            NavigationStack {
                EmptyView()
            }
            .tabItem {
                Image(tabInfo == .setting ? .settingActive : .settingInactive)
                Text(TabInfo.setting.rawValue)
            }
            .tag(TabInfo.setting)
            
        }
        .tint(.green)
    }
}
