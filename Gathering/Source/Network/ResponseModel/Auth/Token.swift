//
//  Token.swift
//  Gathering
//
//  Created by 김성민 on 11/19/24.
//

import Foundation

struct Token: Decodable {
    let accessToken: String
    let refreshToken: String?
}
