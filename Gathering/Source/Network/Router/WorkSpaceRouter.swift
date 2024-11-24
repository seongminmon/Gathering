//
//  WorkSpaceRouter.swift
//  Gathering
//
//  Created by 여성은 on 11/12/24.
//

import Foundation

import Alamofire

enum WorkspaceRouter {
    case fetchMyWorkspaceList    // 내가 속한 워크스페이스 리스트 조회
    case createWorkspace(body: WorkspaceCreateRequest)         // 워크스페이스 생성
    case fetchWorkspaceInfo(workspaceID: String)      // 내가 속한 특정 워크스페이스 정보 조회
    case editWorkspace(workspaceID: String,
                       body: WorkspaceEditRequest)          // 워크스페이스 편집
    case deleteWorkspace(workspaceID: String)         // 워크스페이스 삭제
    case inviteMember(workspaceID: String, body: InviteMemberRequest)            // 워크스페이스 멤버 초대
    case fetchWorkspaceMembers(workspaceID: String)   // 워크스페이스 멤버 조회
    case fetchSpecificMemberInfo(workspaceID: String,
                                 userID: String) // 워크스페이스 특정 멤버 조회
    case searchInWorkspace(workspaceID: String,
                           keyword: String)       // 워크스페이스 내 검색
    case changeWorkspaceAdmin(workspaceID: String,
                              body: OwnerRequest)    // 워크스페이스 관리자 변경
    case leaveWorkspace(workspaceID: String)          // 워크스페이스 나가기
    
}

extension WorkspaceRouter: TargetType {
    var method: HTTPMethod {
        switch self {
        case .fetchMyWorkspaceList,
                .fetchWorkspaceInfo,
                .fetchWorkspaceMembers,
                .fetchSpecificMemberInfo,
                .searchInWorkspace,
                .leaveWorkspace:
            return .get
        case .createWorkspace,
                .inviteMember:
            return .post
        case .editWorkspace,
                .changeWorkspaceAdmin:
            return .put
        case .deleteWorkspace:
            return .delete
        }
    }
    
    var path: String {
        switch self {
        case .fetchMyWorkspaceList:
            return "workspaces"
        case .createWorkspace:
            return "workspaces"
        case .fetchWorkspaceInfo(let workspaceID):
            return "workspaces/\(workspaceID)"
        case .editWorkspace(let workspaceID, _):
            return "workspaces/\(workspaceID)"
        case .deleteWorkspace(let workspaceID):
            return "workspaces/\(workspaceID)"
        case .inviteMember(let workspaceID, _):
            return "workspaces/\(workspaceID)/members"
        case .fetchWorkspaceMembers(let workspaceID):
            return "workspaces/\(workspaceID)/members"
        case .fetchSpecificMemberInfo(let workspaceID, let userID):
            return "workspaces/\(workspaceID)/members/\(userID)"
        case .searchInWorkspace(let workspaceID, _):
            return "workspaces/\(workspaceID)/search"
        case .changeWorkspaceAdmin(let workspaceID, _):
            return "workspaces/\(workspaceID)/transfer/ownership"
        case .leaveWorkspace(let workspaceID):
            return "workspaces/\(workspaceID)/exit"
        }
    }
    
    var headers: HTTPHeaders {
        switch self {
        case .fetchMyWorkspaceList,
                .fetchWorkspaceInfo,
                .deleteWorkspace,
                .inviteMember,
                .fetchWorkspaceMembers,
                .fetchSpecificMemberInfo,
                .searchInWorkspace,
                .changeWorkspaceAdmin,
                .leaveWorkspace:
            return [
                Header.sesacKey.rawValue: APIAuth.key,
                Header.contentType.rawValue: Header.json.rawValue,
                Header.authorization.rawValue: UserDefaultsManager.accessToken
            ]
        case .createWorkspace,
                .editWorkspace:
            return [
                Header.sesacKey.rawValue: APIAuth.key,
                Header.contentType.rawValue: Header.multiPart.rawValue,
                Header.authorization.rawValue: UserDefaultsManager.accessToken
            ]
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .searchInWorkspace(_, let keyword):
            return ["keyword": keyword]
        default:
            return nil
        }
    }

    var body: Data? {
        switch self {
        case .inviteMember(_, let body):
            return try? JSONEncoder().encode(body)
        case .changeWorkspaceAdmin(_, let body):
            return try? JSONEncoder().encode(body)
        default:
            return nil
        }
    }
    
    var multipartData: [MultipartData]? {
        switch self {
        case .createWorkspace(let body):
            return [
                MultipartData(
                    data: body.name.data(using: .utf8) ?? Data(),
                    name: "name"
                ),
                MultipartData(
                    data: body.description?.data(using: .utf8) ?? Data(),
                    name: "description"
                ),
                MultipartData(
                    data: body.image,
                    name: "image",
                    fileName: "image.jpg"
                )
            ]
        case .editWorkspace(_, let body):
            return [
                MultipartData(
                    data: body.name?.data(using: .utf8) ?? Data(),
                    name: "name"
                ),
                MultipartData(
                    data: body.description?.data(using: .utf8) ?? Data(),
                    name: "description"
                ),
                MultipartData(
                    data: body.image ?? Data(),
                    name: "image",
                    fileName: "image.jpg"
                )
            ]
        default:
            return nil
        }
    }
}
