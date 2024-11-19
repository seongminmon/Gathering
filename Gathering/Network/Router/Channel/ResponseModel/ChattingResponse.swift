//
//  ChattingResponse.swift
//  Gathering
//
//  Created by 김성민 on 11/9/24.
//

import Foundation

// MARK: - 채널 채팅 소켓 모델도 공유
struct ChattingResponse: Decodable {
    let channel_id: String
    let channelName: String
    let chat_id: String
    let content: String?
    let createdAt: String
    let files: [String]
    let user: MemberResponse
}
