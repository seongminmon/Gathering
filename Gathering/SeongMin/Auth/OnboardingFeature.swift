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
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case startButtonTap
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .startButtonTap:
                state.isShowPopUpView = true
                return .none
            }
        }
    }
}
