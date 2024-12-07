//
//  DMsRoom.swift
//  Gathering
//
//  Created by 김성민 on 11/21/24.
//

import Foundation

struct DMsRoom: Hashable, Identifiable {
    let id: String
    let createdAt: String
    let user: Member
}

extension DMsRoom {
    func toDBModel(_ members: [MemberDBModel]) -> DMRoomDBModel {
        return DMRoomDBModel(
            roomID: self.id,
            members: members,
            chattings: []
        )
    }
}
