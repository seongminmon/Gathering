//
//  RootFeature.swift
//  Gathering
//
//  Created by dopamint on 11/26/24.
//

import SwiftUI

import ComposableArchitecture

enum TabInfo: String {
    case home = "내 모임"
    case dm = "메시지"
    case explore = "둘러보기"
}

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
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case home(HomeFeature.Action)
        case dm(DMFeature.Action)
        case explore(ExploreFeature.Action)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
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
            case .binding:
                return .none
            case .home, .dm, .explore:
                return .none
            }
        }
    }
}
