//
//  AppFeature.swift
//  Gathering
//
//  Created by 김성민 on 11/17/24.
//

import Foundation

import ComposableArchitecture

@Reducer
struct AppFeature {
    
    enum LoginState {
        case success
        case fail
        case loading
    }
    
    @ObservableState
    struct State {
        var toast: Toast?
        var loginState: LoginState = .loading
    }
    
    enum Action {
        case onAppear
        case showToast(Toast?)
        case task
        case loginSuccess(Token)
        case loginFail
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    let notifications = NotificationCenter.default
                        .notifications(named: .showToast)
                        .map { notification -> Toast? in
                            return notification.toast
                        }
                    
                    for await toast in notifications {
                        if let toast {
                            await send(.showToast(toast))
                            await MainActor.run {
                                ToastWindowManager.shared.showToast(toast: toast)
                            }
                        }
                    }
                }
                
            case .showToast(let toast):
                state.toast = toast
                return .none
                
            case .task:
                // 자동 로그인
                return .run { send in
                    do {
                        let result: Token = try await NetworkManager.shared.request(
                            api: AuthRouter.refreshToken(
                                refreshToken: UserDefaultsManager.refreshToken
                            )
                        )
                        await send(.loginSuccess(result))
                        
                    } catch {
                        await send(.loginFail)
                    }
                }
                
            case .loginSuccess(let value):
                print("자동 로그인 성공")
                // 엑세스 토큰 저장
                UserDefaultsManager.refresh(value.accessToken)
                state.loginState = .success
                return .none
                
            case .loginFail:
                print("자동 로그인 실패 (리프레시 토큰 만료)")
                state.loginState = .fail
                return .none
            }
        }
    }
}
