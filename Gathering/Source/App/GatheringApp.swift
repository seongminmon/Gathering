//
//  GatheringApp.swift
//  Gathering
//
//  Created by 김성민 on 11/1/24.
//

import SwiftUI

import ComposableArchitecture

// TODO: -
// [] 테스트 코드 작성

// - 이미지 캐싱
// [] 메모리 캐시 정책 살펴보기
// [] 디스크 캐싱 500MB 제한, LRU 사용

// - 소켓
// [] 모임 채팅뷰, DM 채팅뷰 onDisappear 시점에 소켓 Deinit 하도록 만들기
// [] 소켓 매니저 디펜던시로 만들기
// [] 백그라운드 진입 시 소켓 해제, 포어그라운드 재 진입 시 소켓 재연결

// - DB
// [] DB 안정화 - 채팅 목록 로드 중 세팅 뷰에 들어갔다가 홈 화면으로 나갈 시 오류 해결

// - 채팅 뷰
// [] 채팅뷰 진입 시 시간 단축
// [] 채팅 UI GeometryReader 사용하여 다양한 기기 대응
// [] 채팅 뷰 컴포넌트로 만들기

@main
struct GatheringApp: App {
    
    @Perception.Bindable var store =  Store(initialState: AppFeature.State()) { AppFeature() }
    
    init() {
        ImageFileManager.shared.createImageDirectory()
    }
    
    var body: some Scene {
        WindowGroup {
            WithPerceptionTracking {
                rootView()
                    .onAppear { store.send(.onAppear) }
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
