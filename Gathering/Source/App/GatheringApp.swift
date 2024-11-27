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
            if let loginState = notification.userInfo?[
                Notification.UserInfoKey.changeRoot
            ] as? AppFeature.LoginState {
                store.send(.updateLoginState(loginState), animation: .easeOut)
            }
        }
    }
}
