//
//  MemberResponse.swift
//  Gathering
//
//  Created by 김성민 on 11/9/24.
//

import Foundation

struct MemberResponse: Decodable {
    let user_id: String
    let email: String
    let nickname: String
    let profileImage: String?
}

extension MemberResponse {
    var toMember: Member {
        return Member(
            id: self.user_id,
            email: self.email,
            nickname: self.nickname,
            profileImage: self.profileImage
        )
    }
}

struct Member: Hashable, Identifiable {
    let id: String
    let email: String
    let nickname: String
    let profileImage: String?
}
