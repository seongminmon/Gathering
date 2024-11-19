//
//  WorkspaceClient.swift
//  Gathering
//
//  Created by 여성은 on 11/12/24.
//

import Foundation

import ComposableArchitecture

struct WorkspaceClient {
    var fetchMyWorkspaceList: () async throws -> [WorkspaceResponse]
    var createWorkspace: (WorkspaceCreateRequest) async throws -> WorkspaceResponse
    var fetchWorkspaceInfo: (String) async throws -> WorkspaceResponse
    var editWorkspace: (String, WorkspaceEditRequest) async throws -> WorkspaceResponse
    var deleteWorkspace: (String) async throws -> Void
    var inviteMember: (String, InviteMemberRequest) async throws -> MemberResponse
    var fetchWorkspaceMembers: (String) async throws -> [MemberResponse]
    var fetchSpecificMemberInfo: (String, String) async throws -> MemberResponse
    var searchInWorkspace: (String, String) async throws -> WorkspaceResponse
    var changeWorkspaceAdmin: (String, OwnerRequest) async throws -> WorkspaceResponse
    var leaveWorkspace: (String) async throws -> [WorkspaceResponse]
}

extension WorkspaceClient: DependencyKey {
    static let liveValue = WorkspaceClient(
        fetchMyWorkspaceList: { 
            return try await NetworkManager.shared.request(
                api: WorkspaceRouter.fetchMyWorkspaceList
            )
        },
        createWorkspace: { body in
            return try await NetworkManager.shared.request(
                api: WorkspaceRouter.createWorkspace(body: body)
            )
        },
        fetchWorkspaceInfo: { workspaceID in
            return try await NetworkManager.shared.request(
                api: WorkspaceRouter.fetchWorkspaceInfo(
                    workspaceID: workspaceID
                )
            )
        },
        editWorkspace: { workspaceID, body in
            return try await NetworkManager.shared.request(
                api: WorkspaceRouter.editWorkspace(
                    workspaceID: workspaceID,
                    body: body
                )
            )
        },
        deleteWorkspace: { workspaceID in
            return try await NetworkManager.shared.requestWithoutResponse(
                api: WorkspaceRouter.deleteWorkspace(
                    workspaceID: workspaceID
                )
            )
        },
        inviteMember: { workspaceID, body in
            return try await NetworkManager.shared.request(
                api: WorkspaceRouter.inviteMember(
                    workspaceID: workspaceID,
                    body: body
                )
            )
        },
        fetchWorkspaceMembers: { workspaceID in
            return try await NetworkManager.shared.request(
                api: WorkspaceRouter.fetchWorkspaceMembers(
                    workspaceID: workspaceID
                )
            )
        },
        fetchSpecificMemberInfo: { workspaceID, userID in
            return try await NetworkManager.shared.request(
                api: WorkspaceRouter.fetchSpecificMemberInfo(
                    workspaceID: workspaceID,
                    userID: userID
                )
            )
        },
        searchInWorkspace: { workspaceID, keyword in
            return try await NetworkManager.shared.request(
                api: WorkspaceRouter.searchInWorkspace(
                    workspaceID: workspaceID,
                    keyword: keyword
                )
            )
            
        },
        changeWorkspaceAdmin: { workspaceID, body in
            return try await NetworkManager.shared.request(
                api: WorkspaceRouter.changeWorkspaceAdmin(
                    workspaceID: workspaceID,
                    body: body
                )
            )
        },
        leaveWorkspace: { workspaceID in
            return try await NetworkManager.shared.request(
                api: WorkspaceRouter.fetchWorkspaceInfo(
                    workspaceID: workspaceID
                )
            )
        }
    )
}

extension DependencyValues {
    var workspaceClient: WorkspaceClient {
        get { self[WorkspaceClient.self] }
        set { self[WorkspaceClient.self] = newValue }
    }
}
