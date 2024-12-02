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
    @Persisted var chattings: List<ChannelChattingDBModel>
    
    convenience init(
        roomID: String,
        // MARK: 안되면 []로 바꾸기
        members: List<MemberDBModel>,
        chattings: List<ChannelChattingDBModel>
    ) {
        self.init()
        self.roomID = roomID
        self.members = members
        self.chattings = chattings
    }
}
