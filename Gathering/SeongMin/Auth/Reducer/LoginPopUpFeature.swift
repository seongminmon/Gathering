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
    
    @ObservableState
    struct State {
        var isEmailLoginViewPresented = false
        var isSignUpViewPresented = false
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case emailLoginButtonTap
        case signUpButtonTap
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .emailLoginButtonTap:
                state.isEmailLoginViewPresented = true
                return .none
                
            case .signUpButtonTap:
                state.isSignUpViewPresented = true
                return .none
            }
        }
    }
}
