//
//  SignUpFeature.swift
//  Gathering
//
//  Created by 김성민 on 11/15/24.
//

import ComposableArchitecture

@Reducer
struct SignUpFeature {
    
    @ObservableState
    struct State {
        var emailText = ""
        var nicknameText = ""
        var phoneText = ""
        var passwordText = ""
        var passwordCheckText = ""
        var isButtonValid = false
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
