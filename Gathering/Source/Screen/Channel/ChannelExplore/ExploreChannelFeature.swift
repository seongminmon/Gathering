//
//  ChannelFeature.swift
//  Gathering
//
//  Created by dopamint on 11/15/24.
//

import SwiftUI

import ComposableArchitecture

@Reducer
struct ChannelExploreFeature {
    @ObservableState
    struct State {
        var channels: [Channel] = Dummy.channels
        var selectedChannel: Channel?
        var showCustomAlert = false
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case channelTap(Channel)
        case confirmJoinChannel
        case cancelJoinChannel
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case let .channelTap(channel):
                state.selectedChannel = channel
                state.showCustomAlert = true
                return .none
                
            case .confirmJoinChannel:
                // 여기에 채널 참여 로직 추가
                state.showCustomAlert = false
                return .none
                
            case .cancelJoinChannel:
                state.showCustomAlert = false
                state.selectedChannel = nil
                return .none
            }
        }
    }
}
