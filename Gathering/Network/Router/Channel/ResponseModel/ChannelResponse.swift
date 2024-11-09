//
//  ChannelResponse.swift
//  Gathering
//
//  Created by 김성민 on 11/8/24.
//

import Foundation

struct ChannelResponse: Decodable {
    let channel_id: String
    let name: String
    let description: String
    let coverImage: String
    let owner_id: String
    let createdAt: String
    let channelMembers: [MemberResponse]?
}

struct MemberResponse: Decodable {
    let user_id: String
    let email: String
    let nickname: String
    let profileImage: String
}
