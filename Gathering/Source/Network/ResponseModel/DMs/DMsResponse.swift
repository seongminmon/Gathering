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
    func toChattingPresentModel() -> ChattingPresentModel {
        return ChattingPresentModel(
            id: self.dm_id,
            user: self.user.toMember,
            name: self.user.nickname,
            text: self.content,
            imageNames: self.files,
            isMine: user.user_id == UserDefaultsManager.userID ? true : false,
            profile: user.profileImage
        )
    }
    
    func toRealmModel() -> DMChattingRealmModel {
        let user = self.user.toRealmModel()
        return DMChattingRealmModel(
            dmID: self.dm_id,
            roomID: self.room_id,
            content: self.content,
            createdAt: self.createdAt,
            filesCount: self.files.count,
            user: user
        )
    }
}
