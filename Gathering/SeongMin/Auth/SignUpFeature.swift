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
                // 연락처를 제외한 모든 값(이메일/닉네임/비밀번호/비밀번호 확인)이 입력된 경우 버튼 유효성 업데이트
                state.isButtonValid = !state.emailText.isEmpty &&
                                      !state.nicknameText.isEmpty &&
                                      !state.passwordText.isEmpty &&
                                      !state.passwordCheckText.isEmpty
                
                return .none
            }
        }
    }
}
