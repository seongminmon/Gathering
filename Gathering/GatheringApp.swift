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
                    UserDefaultsManager.accessToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiOTczZDYyZWMtMTc3Ni00NDZmLTkwZWEtZjM1ZDE4OWJiN2IzIiwibmlja25hbWUiOiJrc20xIiwiaWF0IjoxNzMxMzA2NDkwLCJleHAiOjE3MzEzMDY3OTAsImlzcyI6InNscCJ9.8TrfIaccFIIEuWD5ogvN_QetM43sFWlgQ8jGRBOEe4o"
                    
//                    do {
//                        let result: [ChannelResponse] = try await NetworkManager.shared.request(
//                            api: ChannelRouter.exitChannel(channelID: "a", workspaceID: "a")
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
