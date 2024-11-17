//
//  SignUpFeature.swift
//  Gathering
//
//  Created by 김성민 on 11/15/24.
//

import Foundation

import ComposableArchitecture

@Reducer
struct SignUpFeature {
    
    @Dependency(\.userClient) var userClient
    
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
        case phoneTextChange(String)
        case signUpButtonTap
        case signUpResponse(JoinLoginResponse)
        case signUpError(Error)
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
                
            case .phoneTextChange(let value):
                state.phoneText = phoneFormat(value)
                return .none
                
            case .signUpButtonTap:
                // 유효성 검증
                let flag = emailValidation(state.emailText) &&
                nicknameValidation(state.nicknameText) &&
                phoneValidation(state.phoneText) &&
                passwordValidation(state.passwordText) &&
                passwordCheckValidation(state.passwordText, state.passwordCheckText)
                
                print("회원가입 버튼 탭", flag)
                
                // 회원가입 통신
                if flag {
                    return .run { [state = state] send in
                        let request = JoinRequest(
                            email: state.emailText,
                            password: state.passwordText,
                            nickname: state.nicknameText,
                            phone: state.phoneText,
                            deviceToken: nil
                        )
                        do {
                            let result = try await userClient.join(request)
                            await send(.signUpResponse(result))
                        } catch {
                            await send(.signUpError(error))
                        }
                    }
                } else {
                    Notification.postToast(title: "회원가입 유효성 검증 실패")
                    return .none
                }
                
            case .signUpResponse(let data):
                print(data)
                
                // userdefaults에 유저 정보 저장
                UserDefaultsManager.signIn(
                    data.token.accessToken,
                    data.token.refreshToken ?? "",
                    data.userID
                )
                // TODO: - 통신 성공 시 화면 전환
                
                return .none
                
            case .signUpError(let error):
                // 통신 실패 시 토스트 메시지
                print(error)
                Notification.postToast(title: "회원가입 통신 실패")
                return .none
            }
        }
    }
    
    private func emailValidation(_ str: String) -> Bool {
        return str.contains("@") && str.contains(".")
    }
    
    private func nicknameValidation(_ str: String) -> Bool {
        return 1 <= str.count && str.count <= 30
    }
    
    private func phoneFormat(_ str: String) -> String {
        let phoneText = str.filter { $0.isNumber }
        
        if phoneText.count > 11 {
            return phoneFormat(String(phoneText.prefix(11)))
        }
        
        switch phoneText.count {
        case 0...3:
            return phoneText
        case 4...6:
            let prefix = String(phoneText.prefix(3))
            let middle = String(phoneText.suffix(phoneText.count - 3))
            return "\(prefix)-\(middle)"
        case 7...10:
            let prefix = String(phoneText.prefix(3))
            let middle = String(phoneText.dropFirst(3).prefix(3))
            let suffix = String(phoneText.suffix(phoneText.count - 6))
            return "\(prefix)-\(middle)-\(suffix)"
        default:
            let prefix = String(phoneText.prefix(3))
            let middle = String(phoneText.dropFirst(3).prefix(4))
            let suffix = String(phoneText.suffix(4))
            return "\(prefix)-\(middle)-\(suffix)"
        }
    }
    
    // 전화번호 유효성 검증 : 01 로 시작하는 10~11자리 숫자
    private func phoneValidation(_ str: String) -> Bool {
        if str.isEmpty { return true }
        let regex = "^01([0-9])-?([0-9]{3,4})-?([0-9]{4})$"
        return NSPredicate(format: "SELF MATCHES %@", regex)
            .evaluate(with: str)
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
    
    private func passwordCheckValidation(_ str1: String, _ str2: String) -> Bool {
        return str1 == str2
    }
}
