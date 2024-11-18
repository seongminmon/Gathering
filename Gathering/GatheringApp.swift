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
                    .task { store.send(.task) }
            }
        }
    }
    
    @ViewBuilder
    private func rootView() -> some View {
        switch store.loginState {
        case .success:
            RootView()
        case .fail:
            OnboardingView(
                store: Store(initialState: OnboardingFeature.State()) { OnboardingFeature() }
            )
        case .loading:
            ProgressView()
        }
    }
}
