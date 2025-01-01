//
//  LoginPopUpFeature.swift
//  Gathering
//
//  Created by 김성민 on 11/16/24.
//

import Foundation

import ComposableArchitecture
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser

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
        case kakaoLoginButtonTap
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
                
            case .kakaoLoginButtonTap:
                if (UserApi.isKakaoTalkLoginAvailable()) {
                    UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                        print(oauthToken)
                        print(error)
                    }
                } else {
                    UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                        print(oauthToken)
                        print(error)
                    }
                }
                return .none
                
            case .signUpButtonTap:
                state.destination = .signUp(SignUpFeature.State())
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}
