//
//  AuthClient.swift
//  Gathering
//
//  Created by dopamint on 11/12/24.
//

import Foundation

import ComposableArchitecture

struct AuthClient {
    var refreshToken: (String) async throws -> Token
}

extension AuthClient: DependencyKey {
    static let liveValue = AuthClient(
        refreshToken: { token in
            return try await NetworkManager.shared.request(
                api: AuthRouter.refreshToken(refreshToken: token)
            )
        }
    )
}

extension DependencyValues {
    var authClient: AuthClient {
        get { self[AuthClient.self] }
        set { self[AuthClient.self] = newValue }
    }
}
