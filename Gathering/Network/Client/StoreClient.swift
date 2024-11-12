//
//  StoreClient.swift
//  Gathering
//
//  Created by 김성민 on 11/11/24.
//

import Foundation

import ComposableArchitecture

struct StoreClient {
    var payValidation: (PayValidationRequest) async throws -> PayValidationResponse
    var itemList: () async throws -> [StoreItemResponse]
}

extension StoreClient: DependencyKey {
    static let liveValue = StoreClient(
        payValidation: { body in
            return try await NetworkManager.shared.request(
                api: StoreRouter.payValidation(body: body)
            )
        }, itemList: {
            return try await NetworkManager.shared.request(
                api: StoreRouter.itemList
            )
        }
    )
}

extension DependencyValues {
    var storeClient: StoreClient {
        get { self[StoreClient.self] }
        set { self[StoreClient.self] = newValue }
    }
}
