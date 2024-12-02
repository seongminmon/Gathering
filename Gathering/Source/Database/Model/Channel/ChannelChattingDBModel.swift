//
//  ChannelChattingDBModel.swift
//  Gathering
//
//  Created by 김성민 on 11/19/24.
//

import Foundation

import RealmSwift

class ChannelChattingDBModel: Object {
//    @Persisted(primaryKey: true) var channelID: String
//    @Persisted var channelName: String
    @Persisted(primaryKey: true) var chatID: String
    @Persisted var content: String?
    @Persisted var createdAt: String
    // 파일매니저에 저장된 채팅에 있는 사진 수
    @Persisted var files: List<String>
    @Persisted var user: MemberDBModel?
    
    convenience init(
//        channelID: String,
//        channelName: String,
        chatID: String,
        content: String?,
        createdAt: String,
        files: [String],
        user: MemberDBModel
    ) {
        self.init()
//        self.channelID = channelID
//        self.channelName = channelName
        self.chatID = chatID
        self.content = content
        self.createdAt = createdAt
        self.files.append(objectsIn: files)
        self.user = user
    }
}

extension ChannelChattingDBModel: Identifiable {}
