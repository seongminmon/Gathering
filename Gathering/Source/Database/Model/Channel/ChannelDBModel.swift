//
//  ChannelDBModel.swift
//  Gathering
//
//  Created by 김성민 on 12/2/24.
//

import Foundation

import RealmSwift

// 채널 채팅방 진입 시
class ChannelDBModel: Object {
    @Persisted(primaryKey: true) var channelID: String
    @Persisted var channelName: String
    @Persisted var members: List<MemberDBModel>
    @Persisted var chattings: List<ChannelChattingDBModel>
//    @Persisted var lastReadDate: String?
    
    convenience init(
        channelID: String,
        channelName: String,
        members: [MemberDBModel],
        chattings: [ChannelChattingDBModel]
    ) {
        self.init()
        self.channelID = channelID
        self.channelName = channelName
        self.members.append(objectsIn: members)
        self.chattings.append(objectsIn: chattings)
//        self.lastReadDate = chattings.last?.createdAt
    }
}
