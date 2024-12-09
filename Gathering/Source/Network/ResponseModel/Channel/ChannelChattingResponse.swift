//
//  ChattingResponse.swift
//  Gathering
//
//  Created by 김성민 on 11/9/24.
//

import Foundation

// MARK: - 채널 채팅 소켓 모델도 공유
struct ChannelChattingResponse: Decodable {
    let channel_id: String
    let channelName: String
    let chat_id: String
    let content: String?
    let createdAt: String
    let files: [String]
    let user: MemberResponse
}

extension ChannelChattingResponse {
    func toDBModel(_ user: MemberDBModel) -> ChannelChattingDBModel {
        return ChannelChattingDBModel(
            chatID: self.chat_id,
            content: self.content,
            createdAt: self.createdAt,
            files: self.files,
            user: user
        )
    }
    
    func toPresentModel() -> ChattingPresentModel {
        return ChattingPresentModel(
            id: self.chat_id, 
            user: self.user.toPresentModel(),
            name: self.user.nickname,
            text: self.content,
            imageNames: self.files, 
            date: self.createdAt,
            isMine: user.user_id == UserDefaultsManager.userID,
            profile: user.profileImage
        )
    }
}
