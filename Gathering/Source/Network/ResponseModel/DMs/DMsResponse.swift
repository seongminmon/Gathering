//
//  DMsResponse.swift
//  Gathering
//
//  Created by 여성은 on 11/12/24.
//

import Foundation

typealias DMs = [DMsResponse]

// MARK: - DM 채팅 소켓 모델도 공유
struct DMsResponse: Decodable {
    let dm_id: String
    let room_id: String
    let content: String?
    let createdAt: String
    let files: [String]
    let user: MemberResponse
}

extension DMsResponse {
    func toDBModel(_ user: MemberDBModel) -> DMChattingDBModel {
        return DMChattingDBModel(
            dmID: self.dm_id,
            content: self.content,
            createdAt: self.createdAt,
            files: self.files,
            user: user
        )
    }
    
    func toPresentModel() -> ChattingPresentModel {
        return ChattingPresentModel(
            id: self.dm_id,
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
