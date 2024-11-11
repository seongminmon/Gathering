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
                    UserDefaultsManager.accessToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNThmYTc2NDgtNzQ3Yi00NjFmLTk1MWEtMjMxNzFhYmYzNjE5Iiwibmlja25hbWUiOiLsg4jsi7kiLCJpYXQiOjE3MzEzNjUxMTMsImV4cCI6MTczMTM2NTQxMywiaXNzIjoic2xwIn0.LlGa-Kt_H3kNcfGMAWH3ZqXy9mYuiF3ottCHudy3R3o"
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
