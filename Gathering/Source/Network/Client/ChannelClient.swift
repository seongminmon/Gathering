//
//  ChannelClient.swift
//  Gathering
//
//  Created by 김성민 on 11/11/24.
//

import Foundation

import ComposableArchitecture

struct ChannelClient {
    var fetchMyChannelList: (String) async throws -> [ChannelResponse]
    var fetchChannelList: (String) async throws -> [ChannelResponse]
    var createChannel: (String, ChannelRequest) async throws -> ChannelResponse
    var fetchChannel: (String, String) async throws -> ChannelResponse
    var editChannel: (String, String, ChannelRequest) async throws -> ChannelResponse
    var deleteChannel: (String, String) async throws -> Void
    var fetchChattingList: (String, String, String) async throws -> [ChannelChattingResponse]
    var sendChatting: (String, String, ChattingRequest) async throws -> ChannelChattingResponse
    var fetchUnreadChannel: (String, String, String) async throws -> UnreadChannelResponse
    var fetchMembers: (String, String) async throws -> [MemberResponse]
    var changeOwner: (String, String, OwnerRequest) async throws -> ChannelResponse
    var exitChannel: (String, String) async throws -> [ChannelResponse]
}

extension ChannelClient: DependencyKey {
    static let liveValue = ChannelClient(
        fetchMyChannelList: { workspaceID in
            return try await NetworkManager.shared.request(
                api: ChannelRouter.fetchMyChannelList(workspaceID: workspaceID)
            )
        },
        fetchChannelList: { workspaceID in
            return try await NetworkManager.shared.request(
                api: ChannelRouter.fetchChannelList(workspaceID: workspaceID)
            )
        },
        createChannel: { workspaceID, body in
            return try await NetworkManager.shared.request(
                api: ChannelRouter.createChannel(workspaceID: workspaceID, body: body)
            )
        },
        fetchChannel: { channelID, workspaceID in
            return try await NetworkManager.shared.request(
                api: ChannelRouter.fetchChannel(channelID: channelID, workspaceID: workspaceID)
            )
        },
        editChannel: { channelID, workspaceID, body in
            return try await NetworkManager.shared.request(
                api: ChannelRouter.editChannel(
                    channelID: channelID,
                    workspaceID: workspaceID,
                    body: body
                )
            )
        },
        deleteChannel: { channelID, workspaceID in
            return try await NetworkManager.shared.requestWithoutResponse(
                api: ChannelRouter.deleteChannel(channelID: channelID, workspaceID: workspaceID)
            )
        },
        fetchChattingList: { channelID, workspaceID, cursorDate in
            return try await NetworkManager.shared.request(
                api: ChannelRouter.fetchChattingList(
                    channelID: channelID,
                    workspaceID: workspaceID,
                    cursorDate: cursorDate
                )
            )
        },
        sendChatting: { channelID, workspaceID, body in
            return try await NetworkManager.shared.request(
                api: ChannelRouter.sendChatting(
                    channelID: channelID,
                    workspaceID: workspaceID,
                    body: body
                )
            )
        },
        fetchUnreadChannel: { channelID, workspaceID, after in
            return try await NetworkManager.shared.request(
                api: ChannelRouter.fetchUnreadCount(
                    channelID: channelID,
                    workspaceID: workspaceID,
                    after: after
                )
            )
        },
        fetchMembers: { channelID, workspaceID in
            return try await NetworkManager.shared.request(
                api: ChannelRouter.fetchMembers(channelID: channelID, workspaceID: workspaceID)
            )
        },
        changeOwner: { channelID, workspaceID, body in
            return try await NetworkManager.shared.request(
                api: ChannelRouter.changeOwner(
                    channelID: channelID,
                    workspaceID: workspaceID,
                    body: body
                )
            )
        },
        exitChannel: { channelID, workspaceID in
            return try await NetworkManager.shared.request(
                api: ChannelRouter.exitChannel(channelID: channelID, workspaceID: workspaceID)
            )
        }
    )
}

extension DependencyValues {
    var channelClient: ChannelClient {
        get { self[ChannelClient.self] }
        set { self[ChannelClient.self] = newValue }
    }
}
