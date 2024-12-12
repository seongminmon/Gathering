//
//  RootFeature.swift
//  Gathering
//
//  Created by dopamint on 11/26/24.
//

import SwiftUI

import ComposableArchitecture

@Reducer
struct RootFeature {
    @ObservableState
    struct State {
        var selectedTab: TabInfo = .home
        var home: HomeFeature.State
        var dm: DMFeature.State
        var explore: ExploreFeature.State
        
        init() {
            self.home = HomeFeature.State()
            self.dm = DMFeature.State()
            self.explore = ExploreFeature.State()
        }
    }
    
    enum Action {
        case setTab(TabInfo)
        case home(HomeFeature.Action)
        case dm(DMFeature.Action)
        case explore(ExploreFeature.Action)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.home, action: \.home) {
            HomeFeature()
        }
        Scope(state: \.dm, action: \.dm) {
            DMFeature()
        }
        Scope(state: \.explore, action: \.explore) {
            ExploreFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .setTab(let tab):
                state.selectedTab = tab
                return .none
                
            case .home(.startNewMessageTap):
                state.selectedTab = .dm
                return .none
            case .home(.floatingButtonTap):
                state.selectedTab = .dm
                return .none
            case .home, .dm, .explore:
                return .none
            }
        }
    }
}
