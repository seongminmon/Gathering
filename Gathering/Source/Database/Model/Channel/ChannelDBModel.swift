//
//  ChannelDBModel.swift
//  Gathering
//
//  Created by 김성민 on 12/2/24.
//

import Foundation

import RealmSwift

class ChannelDBModel: Object {
    @Persisted(primaryKey: true) var channelID: String
    @Persisted var channelName: String
    @Persisted var members: List<MemberDBModel>
    @Persisted var chattings: List<ChannelChattingDBModel>
    
    convenience init(
        channelID: String,
        channelName: String,
        // MARK: 안되면 []로 바꾸기
        members: List<MemberDBModel>,
        chattings: List<ChannelChattingDBModel>
    ) {
        self.init()
        self.channelID = channelID
        self.channelName = channelName
        self.members = members
        self.chattings = chattings
    }
}
