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
                    UserDefaultsManager.accessToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiOTczZDYyZWMtMTc3Ni00NDZmLTkwZWEtZjM1ZDE4OWJiN2IzIiwibmlja25hbWUiOiJrc20xIiwiaWF0IjoxNzMxMDU2OTUzLCJleHAiOjE3MzEwNTcyNTMsImlzcyI6InNscCJ9.shhv9fXXWbN7Rp_Cwjy9VaLm-3VLHPiytfKixspTLQg"
                    
                    do {
                        let result: [StoreItemResponse] = try await NetworkManager.shared.request(
                            api: StoreRouter.payValidation(query: PayValidationRequest(
                                impUID: "imp_123465789012",
                                merchantUID: "muid_ios_1234567890"
                            ))
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
