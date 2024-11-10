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
    let profileImage: String
}
