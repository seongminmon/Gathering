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
    let description: String?
    let coverImage: String?
    let owner_id: String
    let createdAt: String
    let channelMembers: [MemberResponse]?
}

extension ChannelResponse {
    func toDBModel(_ members: [MemberDBModel]) -> ChannelDBModel {
        return ChannelDBModel(
            channelID: self.channel_id,
            channelName: self.name,
            members: members,
            chattings: []
        )
    }
    
    func toPresentModel() -> Channel {
        let members = self.channelMembers?.map { $0.toPresentModel() } ?? []
        return Channel(
            id: self.channel_id,
            name: self.name,
            description: self.description,
            coverImage: self.coverImage,
            owner_id: self.owner_id,
            createdAt: self.createdAt,
            channelMembers: members
        )
    }
}
