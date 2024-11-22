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
    
//    @Dependency(\.realmClient) var realmClient
    
    enum LoginState {
        case success
        case fail
        case loading
    }
    
    @ObservableState
    struct State {
        var toast: Toast?
        var loginState: LoginState = .loading
        
        var onboarding = OnboardingFeature.State()
        
        // MARK: - Realm Test
//        var channelChats: [ChannelChattingRealmModel] = []
//        var dmChats: [DMChattingRealmModel] = []
//        var currentUsers: [MemberRealmModel] = []
    }
    
    enum Action {
        case onAppear
        case showToast(Toast?)
        case task
        case loginSuccess(Token)
        case loginFail
        
        case onboarding(OnboardingFeature.Action)
        
        // MARK: - Realm Test
//        case loadChannelChats
//        case loadDMChats
//        case loadCurrentUsers
//        
//        case addChannelChat(ChannelChattingRealmModel)
//        case addDMChat(DMChattingRealmModel)
//        case addUser(MemberRealmModel)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.onboarding, action: \.onboarding) {
            OnboardingFeature()
        }
        
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
                
            case .onboarding(.loginPopUp(.emailLogin(.logInResponse))):
                print("이메일 로그인 성공!")
                state.loginState = .success
                return .none
                
            case .onboarding(.loginPopUp(.signUp(.signUpResponse))):
                print("회원가입 성공!")
                state.loginState = .success
                return .none
                
            case .onboarding:
                return .none
                
            // MARK: - Realm Test
//            case .loadChannelChats:
//                do {
//                    state.channelChats = try realmClient.fetchAllChannelChats()
//                } catch {
//                    print("catch - loadChannelChats")
//                }
//                
//                return .none
//                
//            case .loadDMChats:
//                do {
//                    state.dmChats = try realmClient.fetchAllDMChats()
//                } catch {
//                    print("catch - loadDMChats")
//                }
//                return .none
//                
//            case .loadCurrentUsers:
//                do {
//                    state.currentUsers = try realmClient.fetchAllMembers()
//                } catch {
//                    print("catch - loadDMChats")
//                }
//                return .none
//                
//            case .addUser(let data):
//                do {
//                    try realmClient.create(data)
//                    state.currentUsers.append(data)
//                    return .none
//                } catch {
//                    return .none
//                }
//                
//            case .addChannelChat(let data):
//                do {
//                    try realmClient.create(data)
//                    state.channelChats.append(data)
//                    return .none
//                } catch {
//                    return .none
//                }
//                
//            case .addDMChat(let data):
//                do {
//                    try realmClient.create(data)
//                    state.dmChats.append(data)
//                    return .none
//                } catch {
//                    return .none
//                }
            }
        }
    }
}
