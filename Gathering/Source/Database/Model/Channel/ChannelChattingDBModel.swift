//
//  ChannelChattingDBModel.swift
//  Gathering
//
//  Created by 김성민 on 11/19/24.
//

import Foundation

import RealmSwift

class ChannelChattingDBModel: Object {
    @Persisted(primaryKey: true) var chatID: String
    @Persisted var content: String?
    @Persisted var createdAt: String
    @Persisted var files: List<String>
    @Persisted var user: MemberDBModel?
    
    convenience init(
        chatID: String,
        content: String?,
        createdAt: String,
        files: [String],
        user: MemberDBModel
    ) {
        self.init()
        self.chatID = chatID
        self.content = content
        self.createdAt = createdAt
        self.files.append(objectsIn: files)
        self.user = user
    }
}

extension ChannelChattingDBModel {
    func toPresentModel() -> ChattingPresentModel {
        return ChattingPresentModel(
            id: self.chatID,
            user: self.user?.toPresentModel() ?? Member(id: "", email: "", nickname: "", profileImage: ""),
            name: self.user?.nickname ?? "",
            text: self.content,
            imageNames: Array(self.files),
            isMine: self.user?.userID == UserDefaultsManager.userID ? true : false,
            profile: self.user?.profileImage
        )
    }
}
