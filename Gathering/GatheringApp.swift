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
            // MARK: - 네트워크 테스트
                .task {
                    UserDefaultsManager.accessToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiOTczZDYyZWMtMTc3Ni00NDZmLTkwZWEtZjM1ZDE4OWJiN2IzIiwibmlja25hbWUiOiJrc20xIiwiaWF0IjoxNzMxMTIwNTc4LCJleHAiOjE3MzExMjA4NzgsImlzcyI6InNscCJ9.YMskSDBa7Rw3T0wSXR1vEsh8A0TKkvyReaSWtqHpTBk"
                    
                    do {
                        let result: ChattingResponse = try await NetworkManager.shared.request(
                            api: ChannelRouter.fetchUnreadCount(channelID: "a", workspaceID: "a", after: "")
                        )
                        print("Success: \(result)")
                    } catch let error as ErrorResponse {
                        print("Error code: \(error.errorCode)")
                    } catch {
                        print("Unexpected error: \(error)")
                    }
                }
        }
    }
}
