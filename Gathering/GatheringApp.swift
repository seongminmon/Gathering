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
                    UserDefaultsManager.accessToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiOTczZDYyZWMtMTc3Ni00NDZmLTkwZWEtZjM1ZDE4OWJiN2IzIiwibmlja25hbWUiOiJrc20xIiwiaWF0IjoxNzMxMTIyNTA3LCJleHAiOjE3MzExMjI4MDcsImlzcyI6InNscCJ9.iHYGrKErXeL79IkTdn8fhJk1ESo8AXSASm9w5bKS1QM"
                    
                    do {
                        let result: [ChannelResponse] = try await NetworkManager.shared.request(
                            api: ChannelRouter.exitChannel(channelID: "a", workspaceID: "a")
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
