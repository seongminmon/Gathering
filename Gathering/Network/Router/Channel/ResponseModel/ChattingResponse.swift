//
//  ChattingResponse.swift
//  Gathering
//
//  Created by 김성민 on 11/9/24.
//

import Foundation

struct ChattingResponse: Decodable {
    let channel_id: String
    let channelName: String
    let chat_id: String
    let content: String
    let createdAt: String
    let files: [String]
    let user: MemberResponse
}
