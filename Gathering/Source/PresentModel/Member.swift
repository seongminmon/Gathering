//
//  Member.swift
//  Gathering
//
//  Created by 김성민 on 11/21/24.
//

import Foundation

struct Member: Hashable, Identifiable {
    let id: String
    let email: String
    let nickname: String
    let profileImage: String?
}

extension Member {
    func toDBModel() -> MemberDBModel {
        return MemberDBModel(
            userID: self.id,
            email: self.email,
            nickname: self.nickname,
            profileImage: self.profileImage
        )
    }
}
