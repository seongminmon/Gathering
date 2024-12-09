//
//  DMChattingDBModel.swift
//  Gathering
//
//  Created by 김성민 on 11/19/24.
//

import Foundation

import RealmSwift

class DMChattingDBModel: Object {
    @Persisted(primaryKey: true) var dmID: String
    @Persisted var content: String?
    @Persisted var createdAt: String
    @Persisted var files: List<String>
    @Persisted var user: MemberDBModel?
    
    convenience init(
        dmID: String,
        content: String?,
        createdAt: String,
        files: [String],
        user: MemberDBModel
    ) {
        self.init()
        self.dmID = dmID
        self.content = content
        self.createdAt = createdAt
        self.files.append(objectsIn: files)
        self.user = user
    }
}

extension DMChattingDBModel {
    func toPresentModel() -> ChattingPresentModel {
        let user = self.user?.toPresentModel() 
        ?? Member(id: "", email: "", nickname: "", profileImage: "")
        
        return ChattingPresentModel(
            id: self.dmID,
            user: user,
            name: self.user?.nickname ?? "",
            text: self.content,
            imageNames: Array(self.files),
            date: self.createdAt,
            isMine: self.user?.userID == UserDefaultsManager.userID,
            profile: self.user?.profileImage
        )
    }
}
