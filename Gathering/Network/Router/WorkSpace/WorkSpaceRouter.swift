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
    case fetchWorkspaceInfo(worksapceID: String)      // 내가 속한 특정 워크스페이스 정보 조회
    case editWorkspace(worksapceID: String,
                       body: WorkspaceEditRequest)          // 워크스페이스 편집
    case deleteWorkspace(worksapceID: String)         // 워크스페이스 삭제
    case inviteMember(worksapceID: String, body: InviteMemberRequest)            // 워크스페이스 멤버 초대
    case fetchWorkspaceMembers(worksapceID: String)   // 워크스페이스 멤버 조회
    case fetchSpecificMemberInfo(worksapceID: String,
                                 userID: String) // 워크스페이스 특정 멤버 조회
    case searchInWorkspace(worksapceID: String,
                           keyword: String)       // 워크스페이스 내 검색
    case changeWorkspaceAdmin(worksapceID: String, 
                              body: OwnerRequest)    // 워크스페이스 관리자 변경
    case leaveWorkspace(worksapceID: String)          // 워크스페이스 나가기
    
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
        case .fetchWorkspaceInfo(let worksapceID):
            return "workspaces/\(worksapceID)"
        case .editWorkspace(let worksapceID, _):
            return "workspaces/\(worksapceID)"
        case .deleteWorkspace(let worksapceID):
            return "workspaces/\(worksapceID)"
        case .inviteMember(let worksapceID, _):
            return "workspaces/\(worksapceID)/members"
        case .fetchWorkspaceMembers(let worksapceID):
            return "workspaces/\(worksapceID)/members"
        case .fetchSpecificMemberInfo(let worksapceID, let userID):
            return "workspaces/\(worksapceID)/members/\(userID)"
        case .searchInWorkspace(let worksapceID, _):
            return "workspaces/\(worksapceID)/search"
        case .changeWorkspaceAdmin(let worksapceID, _):
            return "workspaces/\(worksapceID)/transfer/ownership"
        case .leaveWorkspace(let worksapceID):
            return "workspaces/\(worksapceID)/exit"
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
        case .createWorkspace(let body):
            return try? JSONEncoder().encode(body)
        case .editWorkspace(_, let body):
            return try? JSONEncoder().encode(body)
        case .inviteMember(_, let body):
            return try? JSONEncoder().encode(body)
        case .changeWorkspaceAdmin(_, let body):
            return try? JSONEncoder().encode(body)
        default:
            return nil
        }
    }
    

}
