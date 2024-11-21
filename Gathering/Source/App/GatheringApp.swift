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
    
    let store = Store(initialState: AppFeature.State()) { AppFeature() }
    
    var body: some Scene {
        WindowGroup {
            WithPerceptionTracking {
                rootView()
                    .onAppear { store.send(.onAppear) }
                    .task { await store.send(.task).finish() }
            }
        }
        
    }
    
    @ViewBuilder
    private func rootView() -> some View {
        Group {
            switch store.loginState {
            case .success:
                RootView()
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
            if let loginState = notification.userInfo?[Notification.UserInfoKey.changeRoot] as? AppFeature.LoginState {
                
                store.send(.updateLoginState(loginState), animation: .easeOut)
            }
        }
    }
}
