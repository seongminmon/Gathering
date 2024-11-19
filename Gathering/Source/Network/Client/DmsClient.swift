//
//  DmsClient.swift
//  Gathering
//
//  Created by 여성은 on 11/12/24.
//

import Foundation

import ComposableArchitecture

struct DmsClient {
    var fetchOrCreateDM: (String, DmOpponentRequest) async throws -> DmsRoomResponse
    var fetchDMSList: (String) async throws -> [DmsRoomResponse]
    var sendDMMessage: (String, String, DmMessageRequest) async throws -> DmsResponse
    var fetchDMChatHistory: (String, String, String) async throws -> [DmsResponse]
    var fetchUnreadDMCount: (String, String, String) async throws -> UnreadCountResponse
}

extension DmsClient: DependencyKey {
    static let liveValue = DmsClient(
        fetchOrCreateDM: { workspaceID, body in
            return try await NetworkManager.shared.request(
                api: DmsRouter.fetchOrCreateDM(
                    workspaceID: workspaceID,
                    body: body
                )
            )
        },
        fetchDMSList: { workspaceID in
            return try await NetworkManager.shared.request(
                api: DmsRouter.fetchDMSList(
                    workspaceID: workspaceID
                )
            )
        },
        sendDMMessage: { workspaceID, roomID, body in
            return try await NetworkManager.shared.request(
                api: DmsRouter.sendDMMessage(
                    workspaceID: workspaceID,
                    roomID: roomID,
                    body: body
                )
            )
        },
        fetchDMChatHistory: { workspaceID, roomID, cursorDate in
            return try await NetworkManager.shared.request(
                api: DmsRouter.fetchDMChatHistory(
                    workspaceID: workspaceID,
                    roomID: roomID,
                    cursorDate: cursorDate
                )
            )
        },
        fetchUnreadDMCount: { workspaceID, roomID, after in
            return try await NetworkManager.shared.request(
                api: DmsRouter.fetchUnreadDMCount(
                    workspaceID: workspaceID,
                    roomID: roomID,
                    after: after
                )
            )
        }
    )
}
extension DependencyValues {
    var dmsClient: DmsClient {
        get { self[DmsClient.self] }
        set { self[DmsClient.self] = newValue }
    }
}
