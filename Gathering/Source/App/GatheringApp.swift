//
//  GatheringApp.swift
//  Gathering
//
//  Created by 김성민 on 11/1/24.
//

import SwiftUI

import ComposableArchitecture

// TODO: -
// ✅ 채널 채팅 로직
// DM 채팅 로직

// ✅ 소켓 통신 매니저
// ❌ 소켓 클라이언트
// ⚠️ 소켓 채팅뷰에 붙이기

// 홈 뷰 DB 관련 로직
// DM 뷰 DB 관련 로직

// 채팅 이미지 뷰 1~5개 표시
// ✅ 채널 채팅, DM 채팅 뷰 로직 (포토 x자 누르면 삭제하기)

// ✅ 채널 삭제, 채널 나가기 시 DB 삭제 >> 채널 세팅
// 로그아웃 시 UserDefaults, DB, 파일매니저 싹 다 지우기

@main
struct GatheringApp: App {
    
    @Perception.Bindable var store =  Store(initialState: AppFeature.State()) { AppFeature() }
    
    // MARK: - realm 경로 출력
    @Dependency(\.dbClient) var dbClient
    
    var body: some Scene {
        WindowGroup {
            WithPerceptionTracking {
                rootView()
                    .onAppear {
                        // realm 경로 출력
                        dbClient.printRealm()
                        store.send(.onAppear)
                    }
                    .task { store.send(.task) }
            }
        }
    }
    
    @ViewBuilder
    private func rootView() -> some View {
        Group {
            switch store.loginState {
            case .success:
                RootView(
                    store: store.scope(state: \.root, action: \.root)
                )
            case .fail:
                OnboardingView(
                    store: store.scope(state: \.onboarding, action: \.onboarding)
                )
            case .loading:
                ProgressView()
            }
        }
        .onReceive(
            NotificationCenter.default.publisher(for: .changeRoot)
        ) { notification in
            if let loginState = notification.userInfo?[
                Notification.UserInfoKey.changeRoot
            ] as? AppFeature.LoginState {
                store.send(.updateLoginState(loginState), animation: .easeOut)
            }
        }
    }
}
