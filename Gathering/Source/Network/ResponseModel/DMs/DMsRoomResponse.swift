//
//  DMsRoomResponse.swift
//  Gathering
//
//  Created by 여성은 on 11/12/24.
//

import Foundation

typealias DMsRooms = [DMsRoomResponse]

struct DMsRoomResponse: Decodable {
    let room_id: String
    let createdAt: String
    let user: MemberResponse
}

extension DMsRoomResponse {
    var toDmsRoom: DMsRoom {
        return DMsRoom(
            id: self.room_id,
            createdAt: self.createdAt,
            user: self.user.toMember
        )
    }
}
