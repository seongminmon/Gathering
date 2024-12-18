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
    
    @Dependency(\.dbClient) var dbClient
    
    @ObservableState
    struct State {
        var toast: Toast?
        var loginState: LoginState = .loading
        var onboarding = OnboardingFeature.State()
        var root = RootFeature.State()
    }
    
    enum Action {
        case onAppear
        case loginSuccess(Token)
        case loginFail
        case updateLoginState(LoginState)
        case onboarding(OnboardingFeature.Action)
        case root(RootFeature.Action)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.onboarding, action: \.onboarding) {
            OnboardingFeature()
        }
        Scope(state: \.root, action: \.root) {
            RootFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                // realm 경로 출력
                dbClient.printRealm()
                
                return .run { send in
                    // 자동 로그인
                    do {
                        let result: Token = try await NetworkManager.shared.request(
                            api: AuthRouter.refreshToken(
                                refreshToken: UserDefaultsManager.refreshToken
                            )
                        )
                        await send(.loginSuccess(result), animation: .easeIn)
                    } catch {
                        await send(.loginFail, animation: .easeIn)
                    }
                    
                    // 토스트 Notification 구독
                    let notifications = NotificationCenter.default
                        .notifications(named: .showToast)
                        .map { notification -> Toast? in
                            return notification.toast
                        }
                    
                    for await toast in notifications {
                        if let toast {
                            await MainActor.run {
                                ToastWindowManager.shared.showToast(toast: toast)
                            }
                        }
                    }
                }
                
            case .loginSuccess(let value):
                print("자동 로그인 성공")
                UserDefaultsManager.refresh(value.accessToken)
                state.loginState = .success
                return .none
                
            case .loginFail:
                print("자동 로그인 실패 (리프레시 토큰 만료)")
                state.loginState = .fail
                Notification.changeRoot(.fail)
                UserDefaultsManager.removeAll()
                do {
                    try dbClient.removeAll()
                } catch {}
                ImageFileManager.shared.deleteAllImages()
                return .none
                
            case .onboarding(.loginPopUp(.emailLogin(.logInResponse))):
                state.loginState = .success
                return .none
                
            case .onboarding(.loginPopUp(.signUp(.signUpResponse))):
                state.loginState = .success
                return .none
                
            case .onboarding:
                return .none
                
            case .root:
                return .none
                
            case let .updateLoginState(newState):
                state.loginState = newState
                return .none
            }
        }
    }
}
