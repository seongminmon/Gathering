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
    @State var isLogin = false
    
    var body: some Scene {
        WindowGroup {
            if isLogin {
                RootView()
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
            } else {
                OnboardingView(
                    store: Store(initialState: OnboardingFeature.State()) { OnboardingFeature() }
                )
                .task {
                    UserDefaultsManager.accessToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiOTczZDYyZWMtMTc3Ni00NDZmLTkwZWEtZjM1ZDE4OWJiN2IzIiwibmlja25hbWUiOiJrc20xIiwiaWF0IjoxNzMxNjU0OTU0LCJleHAiOjE3MzE2NTUyNTQsImlzcyI6InNscCJ9.rfucZPQ_mqMg5VxhZ7LkXO9N3glVG07s_yTXD1G-Pbk"
                    
                    UserDefaultsManager.refreshToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiOTczZDYyZWMtMTc3Ni00NDZmLTkwZWEtZjM1ZDE4OWJiN2IzIiwiaWF0IjoxNzMxNjU0OTU0LCJleHAiOjE3MzE2NTg1NTQsImlzcyI6InNscCJ9.fZuxhT2z-L9MTnTZ_8BULK-Fsp1i6i7Qg_2Zu2_LjhY"
  
                    // 토큰 갱신 테스트
//                    do {
//                        let result: Token = try await NetworkManager.shared.request(
//                            api: AuthRouter.refreshToken(refreshToken: UserDefaultsManager.refreshToken)
//                        )
//                        print(result)
//                    } catch {
//                        print("error")
//                    }
                    
                    // MARK: - 네트워크 테스트
                    do {
                        let result: [WorkspaceResponse] = try await NetworkManager.shared.request(api: WorkspaceRouter.fetchMyWorkspaceList)
                        print(result)
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
}
