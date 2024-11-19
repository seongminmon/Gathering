//
//  OnboardingFeature.swift
//  Gathering
//
//  Created by 김성민 on 11/12/24.
//

import ComposableArchitecture

@Reducer
struct OnboardingFeature {
    
    @ObservableState
    struct State {
        var isShowPopUpView = false
        
        var loginPopUp = LoginPopUpFeature.State()
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case startButtonTap
        
        case loginPopUp(LoginPopUpFeature.Action)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.loginPopUp, action: \.loginPopUp) {
            LoginPopUpFeature()
        }
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .startButtonTap:
                state.isShowPopUpView = true
                return .none
                
            case .loginPopUp:
                return .none
            }
        }
    }
}
