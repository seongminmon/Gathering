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
        
        var emailLogin = EmailLoginFeature.State()
        var signUp = SignUpFeature.State()
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case emailLoginButtonTap
        case signUpButtonTap
        
        case emailLogin(EmailLoginFeature.Action)
        case signUp(SignUpFeature.Action)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.emailLogin, action: \.emailLogin) {
            EmailLoginFeature()
        }
        Scope(state: \.signUp, action: \.signUp) {
            SignUpFeature()
        }
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
                
            case .emailLogin:
                return .none
                
            case .signUp:
                return .none
            }
        }
    }
}
