//
//  ChannelSettingFeature.swift
//  Gathering
//
//  Created by dopamint on 11/21/24.
//

import SwiftUI

import ComposableArchitecture

@Reducer
struct ChannelSettingFeature {
    
    @Reducer
    enum Path {

    }
    
    @ObservableState
    struct State {
        var path = StackState<Path.State>()

    }
    
    enum Action {
        case path(StackActionOf<Path>)
    }
    
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            switch action {

            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
    
}
