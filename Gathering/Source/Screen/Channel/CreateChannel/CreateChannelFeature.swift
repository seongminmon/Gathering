//
//  CreateChannelFeature.swift
//  Gathering
//
//  Created by dopamint on 11/15/24.
//

import SwiftUI

import ComposableArchitecture

@Reducer
struct CreateChannelFeature {
    @ObservableState
    struct State {
        var channelName: String = ""
        var channelDescription: String = ""
        var isValid: Bool {
            !channelName.isEmpty && !channelDescription.isEmpty
        }
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case saveButtonTapped
    }
    
    @Dependency(\.dismiss) var dismiss
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .saveButtonTapped:
                guard state.isValid else { return .none }
                return .run { _ in
                    await self.dismiss()
                }
            }
        }
    }
}
