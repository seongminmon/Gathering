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
    
    @State private var toast: Toast?
    @State private var isLogin = false
    
    var body: some Scene {
        WindowGroup {
            rootView()
                .onAppear {
                    // Toast NotificationCenter 구독
                    NotificationCenter.default.addObserver(
                        forName: .showToast,
                        object: nil,
                        queue: .main
                    ) { notification in
                        if let toast = notification.toast {
                            self.toast = toast
                            ToastWindowManager.shared.showToast(toast: self.$toast)
                        }
                    }
                }
                .task {
                    // TODO: - 자동 로그인 시 네트워크 통신 중 OnboardingView가 보였다가 전환됨
                    // 자동 로그인
                    do {
                        let result: Token = try await NetworkManager.shared.request(
                            api: AuthRouter.refreshToken(
                                refreshToken: UserDefaultsManager.refreshToken
                            )
                        )
                        // 엑세스 토큰 저장
                        UserDefaultsManager.refresh(result.accessToken)
                        isLogin = true
                        print("자동 로그인 성공")
                    } catch {
                        print("자동 로그인 실패 (리프레시 토큰 만료)")
                        isLogin = false
                    }
                }
        }
    }
    
    @ViewBuilder
    private func rootView() -> some View {
        if isLogin {
            RootView()
        } else {
            OnboardingView(
                store: Store(initialState: OnboardingFeature.State()) { OnboardingFeature() }
            )
        }
    }
}
