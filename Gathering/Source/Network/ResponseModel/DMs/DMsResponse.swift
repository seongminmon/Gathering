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
    
    func toDBModel() -> DMChattingDBModel {
        let user = self.user.toDBModel()
        return DMChattingDBModel(
            dmID: self.dm_id,
            roomID: self.room_id,
            content: self.content,
            createdAt: self.createdAt,
            files: self.files,
            // TODO: - 새로 인스턴스 만들어서 넣는게 아니라 기존 채널 채팅방의 멤버들에서 찾아서 넣기
            user: user
        )
    }
}
