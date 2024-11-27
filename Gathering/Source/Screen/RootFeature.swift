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
        
        init() {
            self.home = HomeFeature.State()
            self.dm = DMFeature.State()
        }
    }
    
    enum Action {
        case home(HomeFeature.Action)
        case dm(DMFeature.Action)
        case setTab(TabInfo)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .setTab(let tab):
                state.selectedTab = tab
                return .none
                
            case .home, .dm:
                return .none
            }
        }
        Scope(state: \.home, action: \.home) {
            HomeFeature()
        }
        Scope(state: \.dm, action: \.dm) {
            DMFeature()
        }
    }
}
