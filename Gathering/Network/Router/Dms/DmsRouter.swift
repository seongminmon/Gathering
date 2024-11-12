//
//  DmsRouter.swift
//  Gathering
//
//  Created by 여성은 on 11/12/24.
//

import Foundation

import Alamofire

enum DmsRouter {
    case fetchOrCreateDM(workspaceID: String,
                         body: DmOpponentRequest)       // DM방 조회(생성)
    case fetchDMSList(workspaceID: String)           // DM방 리스트 조회
    case sendDMMessage(workspaceID: String,
                       roomID: String,
                       body: DmMessageRequest)             // DM 채팅 보내기
    case fetchDMChatHistory(workspaceID: String,
                            roomID: String,
                            cursorDate:String)        // DM 채팅 내역 리스트 조회
    case fetchUnreadDMCount(workspaceID: String,
                            roomID: String,
                            after: String)        // 읽지 않은 DM 채팅 개수
}

extension DmsRouter: TargetType {
    var method: HTTPMethod {
        switch self {
        case .fetchOrCreateDM,
                .sendDMMessage:
            return .post
        case .fetchDMSList,
                .fetchDMChatHistory,
                .fetchUnreadDMCount:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .fetchOrCreateDM(let workspaceID, _):
            return "workspaces/\(workspaceID)/dms"
        case .fetchDMSList(let workspaceID):
            return "workspaces/\(workspaceID)/dms"
        case .sendDMMessage(let workspaceID, let roomID, _):
            return "workspaces/\(workspaceID)/dms/\(roomID)/chats"
        case .fetchDMChatHistory(let workspaceID, let roomID, _):
            return "workspaces/\(workspaceID)/dms/\(roomID)/chats"
        case .fetchUnreadDMCount(let workspaceID, let roomID, _):
            return "workspaces/\(workspaceID)/dms/\(roomID)/unreads"
        }
    }
    
    var headers: Alamofire.HTTPHeaders {
        switch self {
        case .fetchOrCreateDM,
                .fetchDMSList,
                .fetchDMChatHistory,
                .fetchUnreadDMCount:
            return [
                Header.sesacKey.rawValue: APIAuth.key,
                Header.contentType.rawValue: Header.json.rawValue,
                Header.authorization.rawValue: UserDefaultsManager.accessToken
            ]
        case .sendDMMessage(let workspaceID, let roomID, let body):
            return [
                Header.sesacKey.rawValue: APIAuth.key,
                Header.contentType.rawValue: Header.multiPart.rawValue,
                Header.authorization.rawValue: UserDefaultsManager.accessToken
            ]
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .fetchDMChatHistory(_, _, let cursorDate):
            return ["cursor_date": cursorDate]
        case .fetchUnreadDMCount(_, _, let after):
            return ["after": after]
        default:
            return nil
        }
    }
    
    var body: Data? {
        switch self {
        case .fetchOrCreateDM(_, let body):
            return try? JSONEncoder().encode(body)
        case .sendDMMessage(_, _, let body):
            return try? JSONEncoder().encode(body)
        default:
            return nil
        }
    }
    
    
}
