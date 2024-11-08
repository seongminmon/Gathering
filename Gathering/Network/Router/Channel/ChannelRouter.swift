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
    case myChannelList(workspaceID: String)
    // 채널 리스트 조회
    case channelList(workspaceID: String)
    // 채널 생성
    case createChannel(workspaceID: String, body: ChannelRequest)
}

extension ChannelRouter: TargetType {
   
    var method: HTTPMethod {
        switch self {
        case .myChannelList, .channelList:
            return .get
        case .createChannel:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .myChannelList(let workspaceID):
            return "/workspaces/\(workspaceID)/my-channels"
        case .channelList(let workspaceID):
            return "/workspaces/\(workspaceID)/channels"
        case .createChannel(let workspaceID, _):
            return "/workspaces/\(workspaceID)/channels"
        }
    }
    
    var headers: HTTPHeaders {
        switch self {
        case .myChannelList, .channelList, .createChannel:
            return [
                Header.sesacKey.rawValue: APIAuth.key,
                Header.contentType.rawValue: Header.json.rawValue,
                Header.authorization.rawValue: UserDefaultsManager.accessToken
            ]
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .myChannelList, .channelList, .createChannel:
            return nil
        }
    }
    
    var body: Data? {
        switch self {
        case .myChannelList, .channelList:
            return nil
        case .createChannel(_, let body):
            return try? JSONEncoder().encode(body)
        }
    }
}
