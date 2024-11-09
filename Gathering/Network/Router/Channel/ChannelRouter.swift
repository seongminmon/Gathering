//
//  ChannelRouter.swift
//  Gathering
//
//  Created by 김성민 on 11/8/24.
//

import Foundation
import Alamofire

enum ChannelRouter {
    // 내가 속한 채널 리스트 조회
    case fetchMyChannelList(workspaceID: String)
    // 채널 리스트 조회
    case fetchChannelList(workspaceID: String)
    // 채널 생성
    case createChannel(workspaceID: String, body: ChannelRequest)
    // 특정 채널 정보 조회
    case fetchChannel(channelID: String, workspaceID: String)
    // 채널 편집
    case editChannel(channelID: String, workspaceID: String, body: ChannelRequest)
    // 채널 삭제
    case deleteChannel(channelID: String, workspaceID: String)
}

extension ChannelRouter: TargetType {
   
    var method: HTTPMethod {
        switch self {
        case .fetchMyChannelList, .fetchChannelList, .fetchChannel:
            return .get
        case .createChannel:
            return .post
        case .editChannel:
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
        }
    }
    
    var headers: HTTPHeaders {
        switch self {
        case .fetchMyChannelList, .fetchChannelList, .createChannel, .fetchChannel, .editChannel, .deleteChannel:
            return [
                Header.sesacKey.rawValue: APIAuth.key,
                Header.contentType.rawValue: Header.json.rawValue,
                Header.authorization.rawValue: UserDefaultsManager.accessToken
            ]
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .fetchMyChannelList, .fetchChannelList, .createChannel, .fetchChannel, .editChannel, .deleteChannel:
            return nil
        }
    }
    
    var body: Data? {
        switch self {
        case .fetchMyChannelList, .fetchChannelList, .fetchChannel, .deleteChannel:
            return nil
        case .createChannel(_, let body), .editChannel(_, _, let body):
            return try? JSONEncoder().encode(body)
        }
    }
}
