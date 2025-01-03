//
//  ChannelRouter.swift
//  Gathering
//
//  Created by 김성민 on 11/8/24.
//

import Foundation

import Alamofire

enum ChannelRouter {
    // 내가 속한 모임 리스트 조회
    case fetchMyChannelList(workspaceID: String)
    // 모임 리스트 조회
    case fetchChannelList(workspaceID: String)
    // 모임 생성
    case createChannel(workspaceID: String, body: ChannelRequest)
    // 특정 모임 정보 조회
    case fetchChannel(channelID: String, workspaceID: String)
    // 모임 편집
    case editChannel(channelID: String, workspaceID: String, body: ChannelRequest)
    // 모임 삭제
    case deleteChannel(channelID: String, workspaceID: String)
    // 모임 채팅 내역 리스트 조회
    case fetchChattingList(channelID: String, workspaceID: String, cursorDate: String = "")
    // 모임 채팅 보내기
    case sendChatting(channelID: String, workspaceID: String, body: ChattingRequest)
    // 읽지 않은 모임 채팅 개수
    case fetchUnreadCount(channelID: String, workspaceID: String, after: String = "")
    // 모임 멤버 조회
    case fetchMembers(channelID: String, workspaceID: String)
    // 모임 관리자 변경
    case changeOwner(channelID: String, workspaceID: String, body: OwnerRequest)
    // 모임 나가기
    case exitChannel(channelID: String, workspaceID: String)
}

extension ChannelRouter: TargetType {
   
    var method: HTTPMethod {
        switch self {
        case .fetchMyChannelList, 
                .fetchChannelList,
                .fetchChannel,
                .fetchChattingList,
                .fetchUnreadCount,
                .fetchMembers,
                .exitChannel:
            return .get
        case .createChannel, 
                .sendChatting:
            return .post
        case .editChannel, .changeOwner:
            return .put
        case .deleteChannel:
            return .delete
        }
    }
    
    var path: String {
        switch self {
        case .fetchMyChannelList(let workspaceID):
            return "/workspaces/\(workspaceID)/my-channels"
        case .fetchChannelList(let workspaceID):
            return "/workspaces/\(workspaceID)/channels"
        case .createChannel(let workspaceID, _):
            return "/workspaces/\(workspaceID)/channels"
        case .fetchChannel(let channelID, let workspaceID):
            return "/workspaces/\(workspaceID)/channels/\(channelID)"
        case .editChannel(let channelID, let workspaceID, _):
            return "/workspaces/\(workspaceID)/channels/\(channelID)"
        case .deleteChannel(let channelID, let workspaceID):
            return "/workspaces/\(workspaceID)/channels/\(channelID)"
        case .fetchChattingList(let channelID, let workspaceID, _):
            return "/workspaces/\(workspaceID)/channels/\(channelID)/chats"
        case .sendChatting(let channelID, let workspaceID, _):
            return "/workspaces/\(workspaceID)/channels/\(channelID)/chats"
        case .fetchUnreadCount(let channelID, let workspaceID, _):
            return "/workspaces/\(workspaceID)/channels/\(channelID)/unreads"
        case .fetchMembers(channelID: let channelID, workspaceID: let workspaceID):
            return "/workspaces/\(workspaceID)/channels/\(channelID)/members"
        case .changeOwner(let channelID, let workspaceID, _):
            return "/workspaces/\(workspaceID)/channels/\(channelID)/transfer/ownership"
        case .exitChannel(let channelID, let workspaceID):
            return "/workspaces/\(workspaceID)/channels/\(channelID)/exit"
        }
    }
    
    var headers: HTTPHeaders {
        switch self {
        case .fetchMyChannelList, 
                .fetchChannelList,
                .createChannel,
                .fetchChannel,
                .editChannel,
                .deleteChannel,
                .fetchChattingList,
                .fetchUnreadCount,
                .fetchMembers,
                .changeOwner,
                .exitChannel:
            return [
                Header.sesacKey.rawValue: APIAuth.key,
                Header.contentType.rawValue: Header.json.rawValue,
                Header.authorization.rawValue: UserDefaultsManager.accessToken
            ]
        case .sendChatting:
            return [
                Header.sesacKey.rawValue: APIAuth.key,
                Header.contentType.rawValue: Header.multiPart.rawValue,
                Header.authorization.rawValue: UserDefaultsManager.accessToken
            ]
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .fetchMyChannelList, 
                .fetchChannelList,
                .createChannel,
                .fetchChannel,
                .editChannel,
                .deleteChannel,
                .sendChatting,
                .fetchMembers,
                .changeOwner,
                .exitChannel:
            return nil
        case .fetchChattingList(_, _, let cursorDate):
            return ["cursor_date": cursorDate]
        case .fetchUnreadCount(_, _, let after):
            return ["after": after]
        }
    }
    
    var body: Data? {
        switch self {
        case .changeOwner(_, _, let body):
            return try? JSONEncoder().encode(body)
        default:
            return nil
        }
    }
    
    var multipartData: [MultipartData]? {
        switch self {
        case .createChannel(_, let body):
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
                    data: body.image ?? Data(),
                    name: "image",
                    fileName: "image.jpg"
                )
            ]
        case .editChannel(_, _, let body):
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
                    data: body.image ?? Data(),
                    name: "image",
                    fileName: "image.jpg"
                )
            ]
        case .sendChatting(_, _, let body):
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
