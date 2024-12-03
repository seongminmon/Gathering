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
    @Persisted var roomID: String
    @Persisted var content: String?
    @Persisted var createdAt: String
    @Persisted var files: List<String>
    @Persisted var user: MemberDBModel?
    
    convenience init(
        dmID: String,
        roomID: String,
        content: String?,
        createdAt: String,
        files: [String],
        user: MemberDBModel
    ) {
        self.init()
        self.dmID = dmID
        self.roomID = roomID
        self.content = content
        self.createdAt = createdAt
        self.files.append(objectsIn: files)
        self.user = user
    }
}

//extension DMChattingDBModel: Identifiable {
//    func toResponseModel() -> DMsResponse {
//        let user = self.user?.toResponseModel() ?? MemberResponse(
//            user_id: "",
//            email: "",
//            nickname: "",
//            profileImage: nil
//        )
//        return DMsResponse(
//            dm_id: self.dmID,
//            room_id: self.roomID,
//            content: self.content,
//            createdAt: self.createdAt,
//            files: [], // TODO: - 변경 필요
//            user: user
//        )
//    }
//}
