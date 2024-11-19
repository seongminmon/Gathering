//
//  ChannelChattingRealmModel.swift
//  Gathering
//
//  Created by 김성민 on 11/19/24.
//

import Foundation

import RealmSwift

class ChannelChattingRealmModel: Object {
    @Persisted(primaryKey: true) var channelID: String
    @Persisted var channelName: String
    @Persisted var chatID: String
    @Persisted var content: String?
    @Persisted var createdAt: String
    // 채팅에 있는 사진들 (파일매니저에 저장됨)
    // @Persisted var files: [String]
    @Persisted var filesCount: Int

    @Persisted var user: MemberRealmModel
    @Persisted var savedDate: Date
    
    convenience init(
        channelID: String,
        channelName: String,
        chatID: String,
        content: String?,
        createdAt: String,
        filesCount: Int,
        user: MemberRealmModel
    ) {
        self.init()
        self.channelID = channelID
        self.channelName = channelName
        self.chatID = chatID
        self.content = content
        self.createdAt = createdAt
        self.filesCount = filesCount
        self.user = user
        self.savedDate = Date()
    }
}
