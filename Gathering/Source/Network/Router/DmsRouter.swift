//
//  DMsRouter.swift
//  Gathering
//
//  Created by 여성은 on 11/12/24.
//

import Foundation

import Alamofire

enum DMsRouter {
    case fetchOrCreateDM(workspaceID: String,
                         body: DMOpponentRequest)       // DM방 조회(생성)
    case fetchDMSList(workspaceID: String)           // DM방 리스트 조회
    case sendDMMessage(workspaceID: String,
                       roomID: String,
                       body: DMRequest)             // DM 채팅 보내기
    case fetchDMChatHistory(workspaceID: String,
                            roomID: String,
                            cursorDate: String)        // DM 채팅 내역 리스트 조회
    case fetchUnreadDMCount(workspaceID: String,
                            roomID: String,
                            after: String)        // 읽지 않은 DM 채팅 개수
}

extension DMsRouter: TargetType {
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
        case .sendDMMessage:
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
        default:
            return nil
        }
    }
    
    var multipartData: [MultipartData]? {
        switch self {
        case .sendDMMessage(_, _, let body):
            var multipartDataList = [
                MultipartData(
                    data: body.content?.data(using: .utf8) ?? Data(),
                    name: "content"
                )
            ]
            if let files = body.files {
                files.enumerated().forEach { index, imageData in
                    let multipartData = MultipartData(
                        data: imageData,
                        name: "files",
                        fileName: "image\(index).jpg"
                    )
                    multipartDataList.append(multipartData)
                }
            }
            return multipartDataList
        default:
            return nil
        }
    }
}
