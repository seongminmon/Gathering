//
//  DMsRoomResponse.swift
//  Gathering
//
//  Created by 여성은 on 11/12/24.
//

import Foundation

struct DMsRoomResponse: Decodable {
    let room_id: String
    let createdAt: String
    let user: MemberResponse
}

extension DMsRoomResponse {
    func toDBModel(_ members: [MemberDBModel]) -> DMRoomDBModel {
        return DMRoomDBModel(
            roomID: self.room_id,
            members: members,
            chattings: []
        )
    }
    
    func toPresentModel() -> DMsRoom {
        return DMsRoom(
            id: self.room_id,
            createdAt: self.createdAt,
            user: self.user.toPresentModel()
        )
    }
}
