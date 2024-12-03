//
//  DMRoomDBModel.swift
//  Gathering
//
//  Created by 김성민 on 12/2/24.
//

import Foundation

import RealmSwift

class DMRoomDBModel: Object {
    @Persisted(primaryKey: true) var roomID: String
    @Persisted var members: List<MemberDBModel>
    @Persisted var chattings: List<DMChattingDBModel>
    
    convenience init(
        roomID: String,
        members: [MemberDBModel],
        chattings: [DMChattingDBModel]
    ) {
        self.init()
        self.roomID = roomID
        self.members.append(objectsIn: members)
        self.chattings.append(objectsIn: chattings)
    }
}
