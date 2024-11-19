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
                
                // MARK: - URL(+ 헤더) 이미지 Test
//                URLImageView(urlString: "/static/profiles/1731219820927.jpg")
//                    .onAppear {
//                        UserDefaultsManager.accessToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiOTczZDYyZWMtMTc3Ni00NDZmLTkwZWEtZjM1ZDE4OWJiN2IzIiwibmlja25hbWUiOiJrc20xIiwiaWF0IjoxNzMyMDA1NTc5LCJleHAiOjE3MzIwMDU4NzksImlzcyI6InNscCJ9.SXZiBzjGp-_jSiQARtBlLebIhPUGovdB6a3666DJN_8"
//                    }
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
                store: store.scope(state: \.onboarding, action: \.onboarding)
            )
        case .loading:
            ProgressView()
        }
    }
}
