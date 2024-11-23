//
//  DMsClient.swift
//  Gathering
//
//  Created by 여성은 on 11/12/24.
//

import Foundation

import ComposableArchitecture

struct DMsClient {
    var fetchOrCreateDM: (String, DMOpponentRequest) async throws -> DMsRoomResponse
    var fetchDMSList: (String) async throws -> [DMsRoomResponse]
    var sendDMMessage: (String, String, DMRequest) async throws -> DMsResponse
    var fetchDMChatHistory: (String, String, String) async throws -> [DMsResponse]
    var fetchUnreadDMCount: (String, String, String) async throws -> UnreadDMsResponse
}

extension DMsClient: DependencyKey {
    static let liveValue = DMsClient(
        fetchOrCreateDM: { workspaceID, body in
            return try await NetworkManager.shared.request(
                api: DMsRouter.fetchOrCreateDM(
                    workspaceID: workspaceID,
                    body: body
                )
            )
        },
        fetchDMSList: { workspaceID in
            return try await NetworkManager.shared.request(
                api: DMsRouter.fetchDMSList(
                    workspaceID: workspaceID
                )
            )
        },
        sendDMMessage: { workspaceID, roomID, body in
            return try await NetworkManager.shared.request(
                api: DMsRouter.sendDMMessage(
                    workspaceID: workspaceID,
                    roomID: roomID,
                    body: body
                )
            )
        },
        fetchDMChatHistory: { workspaceID, roomID, cursorDate in
            return try await NetworkManager.shared.request(
                api: DMsRouter.fetchDMChatHistory(
                    workspaceID: workspaceID,
                    roomID: roomID,
                    cursorDate: cursorDate
                )
            )
        },
        fetchUnreadDMCount: { workspaceID, roomID, after in
            return try await NetworkManager.shared.request(
                api: DMsRouter.fetchUnreadDMCount(
                    workspaceID: workspaceID,
                    roomID: roomID,
                    after: after
                )
            )
        }
    )
}
extension DependencyValues {
    var dmsClient: DMsClient {
        get { self[DMsClient.self] }
        set { self[DMsClient.self] = newValue }
    }
}
