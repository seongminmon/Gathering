//
//  GatheringApp.swift
//  Gathering
//
//  Created by 김성민 on 11/1/24.
//

import SwiftUI

import ComposableArchitecture

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
