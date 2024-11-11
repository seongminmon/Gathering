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
            do {
                let result: PayValidationResponse = try await NetworkManager.shared.request(
                    api: StoreRouter.payValidation(body: body)
                )
                print("Success: \(result)")
                return result
            } catch let error as ErrorResponse {
                print("Error code: \(error.errorCode)")
                throw error
            } catch {
                print("Unexpected error: \(error)")
                throw error
            }
            
        }, itemList: {
            do {
                let result: [StoreItemResponse] = try await NetworkManager.shared.request(
                    api: StoreRouter.itemList
                )
                print("Success: \(result)")
                return result
            } catch let error as ErrorResponse {
                print("Error code: \(error.errorCode)")
                throw error
            } catch {
                print("Unexpected error: \(error)")
                throw error
            }
        }
    )
}

extension DependencyValues {
    var storeClient: StoreClient {
        get { self[StoreClient.self] }
        set { self[StoreClient.self] = newValue }
    }
}
