//
//  LoginPopUpFeature.swift
//  Gathering
//
//  Created by 김성민 on 11/16/24.
//

import Foundation

import ComposableArchitecture

@Reducer
struct LoginPopUpFeature {
    
    @Reducer
    enum Destination {
        case emailLogin(EmailLoginFeature)
        case signUp(SignUpFeature)
    }
    
    @ObservableState
    struct State {
        @Presents var destination: Destination.State?
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        
        case emailLoginButtonTap
        case signUpButtonTap
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .destination:
                return .none
                
            case .emailLoginButtonTap:
                state.destination = .emailLogin(EmailLoginFeature.State())
                return .none
                
            case .signUpButtonTap:
                state.destination = .signUp(SignUpFeature.State())
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}
