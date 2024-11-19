//
//  MemberRealmModel.swift
//  Gathering
//
//  Created by 김성민 on 11/19/24.
//

import Foundation

import RealmSwift

class MemberRealmModel: Object {
    @Persisted(primaryKey: true) var userID: String
    @Persisted var email: String
    @Persisted var nickname: String
    // 프로필 이미지 (파일매니저에 저장됨)
    // @Persisted var profileImage: String?
    @Persisted var savedDate: Date
    
    convenience init(
        userID: String,
        email: String,
        nickname: String,
        profileImage: String?
    ) {
        self.init()
        self.userID = userID
        self.email = email
        self.nickname = nickname
        self.savedDate = Date()
    }
}
