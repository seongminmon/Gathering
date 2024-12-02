//
//  MemberDBModel.swift
//  Gathering
//
//  Created by 김성민 on 11/19/24.
//

import Foundation

import RealmSwift

class MemberDBModel: Object {
//    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted(primaryKey: true) var userID: String
    @Persisted var email: String
    @Persisted var nickname: String
    @Persisted var profileImage: String?
    // 프로필 이미지 (파일매니저에 저장)
    
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
        self.profileImage = profileImage
    }
}

// MARK: 어디서 필요할까 ~~
//extension MemberRealmModel: Identifiable {
//    func toResponseModel() -> MemberResponse {
//        return MemberResponse(
//            user_id: self.userID,
//            email: self.email,
//            nickname: self.nickname,
//            profileImage: self.profileImage // TODO: - 변경 필요
//        )
//    }
//}
