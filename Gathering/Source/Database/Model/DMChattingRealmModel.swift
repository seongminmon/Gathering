//
//  DMChattingRealmModel.swift
//  Gathering
//
//  Created by 김성민 on 11/19/24.
//

import Foundation

import RealmSwift

class DMChattingRealmModel: Object {
    @Persisted(primaryKey: true) var dmID: String
    @Persisted var roomID: String
    @Persisted var content: String?
    @Persisted var createdAt: String
    // 파일매니저에 저장된 채팅에 있는 사진 수
    @Persisted var filesCount: Int
    @Persisted var user: MemberRealmModel?
    @Persisted var savedDate: Date
    
    convenience init(
        dmID: String,
        roomID: String,
        content: String?,
        createdAt: String,
        filesCount: Int,
        user: MemberRealmModel
    ) {
        self.init()
        self.dmID = dmID
        self.roomID = roomID
        self.content = content
        self.createdAt = createdAt
        self.filesCount = filesCount
        self.user = user
        self.savedDate = Date()
    }
}

extension DMChattingRealmModel: Identifiable {
    func toResponseModel() -> DMsResponse {
        let user = self.user?.toResponseModel() ?? MemberResponse(
            user_id: "",
            email: "",
            nickname: "",
            profileImage: nil
        )
        return DMsResponse(
            dm_id: self.dmID,
            room_id: self.roomID,
            content: self.content,
            createdAt: self.createdAt,
            files: [], // TODO: - 변경 필요
            user: user
        )
    }
}
