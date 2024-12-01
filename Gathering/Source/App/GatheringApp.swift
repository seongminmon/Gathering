//
//  GatheringApp.swift
//  Gathering
//
//  Created by 김성민 on 11/1/24.
//

import SwiftUI

import ComposableArchitecture

// MARK: - 버그 수정
// TODO: - 채널 채팅 뷰 -> 채널 세팅 뷰 이동이 안 되는 문제
// TODO: - 홈 뷰에 DMListView 안 뜨는 문제
// ✅ TODO: - 멀티파트 통신 해결하기 -> 테스트는 DM 채팅(설정 탭)에서

// MARK: - 기능 추가
// TODO: - 채널 탐색 뷰, 팀원 초대 뷰 네트워크 기능 연결
// TODO: - 채널 세팅 뷰 기능 추가
// TODO: - 채널 채팅, DM 채팅 뷰 로직 (포토 x자 누르면 삭제하기)

@main
struct GatheringApp: App {
    
    @Perception.Bindable var store =  Store(initialState: AppFeature.State()) { AppFeature() }
    
    // MARK: - realm 경로 출력
    @Dependency(\.realmClient) var realmClient
    
    var body: some Scene {
        WindowGroup {
            WithPerceptionTracking {
                rootView()
                    .onAppear {
                        // realm 경로 출력
                        realmClient.printRealm()
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
