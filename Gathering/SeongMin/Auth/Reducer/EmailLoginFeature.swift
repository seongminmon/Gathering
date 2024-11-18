//
//  EmailLoginFeature.swift
//  Gathering
//
//  Created by 김성민 on 11/16/24.
//

import Foundation

import ComposableArchitecture

@Reducer
struct EmailLoginFeature {
    
    @Dependency(\.userClient) var userClient
    
    @ObservableState
    struct State {
        var emailText = ""
        var passwordText = ""
        var isButtonValid = false
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case logInButtonTap
        case logInResponse(JoinLoginResponse)
        case logInError(Error)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                // 연락처를 제외한 모든 값(이메일/닉네임/비밀번호/비밀번호 확인)이 입력된 경우 버튼 유효성 업데이트
                state.isButtonValid = !state.emailText.isEmpty &&
                !state.passwordText.isEmpty
                
                return .none
                
            case .logInButtonTap:
                // 유효성 검증
                let flag = emailValidation(state.emailText) &&
                passwordValidation(state.passwordText)
                
                print("로그인 버튼 탭", flag)
                
                // 회원가입 통신
                if flag {
                    return .run { [state = state] send in
                        
                        let request = EmailLoginRequest(
                            email: state.emailText,
                            password: state.passwordText,
                            deviceToken: nil
                        )
                        do {
                            let result = try await userClient.emailLogin(request)
                            await send(.logInResponse(result))
                        } catch {
                            await send(.logInError(error))
                        }
                    }
                } else {
                    Notification.postToast(title: "로그인 유효성 검증 실패")
                    return .none
                }
                
            case .logInResponse(let data):
                print(data)
                
                // userdefaults에 유저 정보 저장
                UserDefaultsManager.signIn(
                    data.token.accessToken,
                    data.token.refreshToken ?? "",
                    data.userID
                )
                // TODO: - 통신 성공 시 홈 화면 전환
                
                return .none
                
            case .logInError(let error):
                // 통신 실패 시 토스트 메시지
                print(error)
                Notification.postToast(title: "로그인 통신 실패")
                return .none
            }
        }
    }
    
    private func emailValidation(_ str: String) -> Bool {
        return str.contains("@") && str.contains(".com")
    }
    
    private func passwordValidation(_ str: String) -> Bool {
        // 조건별 정규식
        let hasUppercase = NSPredicate(format: "SELF MATCHES %@", ".*[A-Z].*")
        let hasLowercase = NSPredicate(format: "SELF MATCHES %@", ".*[a-z].*")
        let hasDigit = NSPredicate(format: "SELF MATCHES %@", ".*[0-9].*")
        let hasSpecialCharacter = NSPredicate(
            format: "SELF MATCHES %@", ".*[!@#$%^&*(),.?\":{}|<>].*"
        )
        
        return 8 <= str.count &&
        hasUppercase.evaluate(with: str) &&
        hasLowercase.evaluate(with: str) &&
        hasDigit.evaluate(with: str) &&
        hasSpecialCharacter.evaluate(with: str)
    }
}
