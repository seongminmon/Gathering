//
//  InviteMemberFeature.swift
//  Gathering
//
//  Created by dopamint on 11/15/24.
//

import SwiftUI

import ComposableArchitecture

@Reducer
struct InviteMemberFeature {
    
    @ObservableState
    struct State {
        
    }
    
    enum Action: BindableAction {
        
        case binding(BindingAction<State>)

    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            }
        }
    }
}
