//
//  DmsResponse.swift
//  Gathering
//
//  Created by 여성은 on 11/12/24.
//

import Foundation

typealias Dms = [DmsResponse]

// MARK: - DM 채팅 소켓 모델도 공유
struct DmsResponse: Decodable {
    let dm_id: String
    let room_id: String
    let content: String?
    let createdAt: String
    let files: [String]
    let user: MemberResponse
}

extension DmsResponse {
    var toChattingPresentModel: ChattingPresentModel {
        return ChattingPresentModel(
            name: self.dm_id,
            age: self.createdAt
        )
    }
}
