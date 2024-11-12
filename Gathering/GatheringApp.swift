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
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .task {
                    // MARK: - 네트워크 테스트
                    UserDefaultsManager.accessToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNThmYTc2NDgtNzQ3Yi00NjFmLTk1MWEtMjMxNzFhYmYzNjE5Iiwibmlja25hbWUiOiLsg4jsi7kiLCJpYXQiOjE3MzEzNzU5NzgsImV4cCI6MTczMTM3NjI3OCwiaXNzIjoic2xwIn0.3IeHZ24vVokS1UAoB4kF7ZJcH3agUps7qwSnIrhe4wk"
//                    do {
//                        let result: [WorkspaceInfoResponse] = try await NetworkManager.shared.request(
//                            api: WorkspaceRouter.fetchWorkspaceInfo(worksapceID: "27f9e590-f3e8-41c5-a448-88e1b9f656b7")
//                        )
//                        print("Success: \(result)")
//                    } catch let error as ErrorResponse {
//                        print("Error code: \(error.errorCode)")
//                    } catch {
//                        print("Unexpected error: \(error)")
//                    }
                }
        }
    }
}
