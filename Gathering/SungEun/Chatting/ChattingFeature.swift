//
//  ChattingFeature.swift
//  Gathering
//
//  Created by 여성은 on 11/19/24.
//

import SwiftUI

import ComposableArchitecture

@Reducer
struct ChannelFeature {

    @ObservableState
    struct State {
        var messageText = ""
        var messages = ChannelDummy.messages
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case sendMessage
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .sendMessage:
                return .none
            }
        }
    }
}

