//
//  KakaoLoginRequest.swift
//  Gathering
//
//  Created by dopamint on 11/12/24.
//

import Foundation

struct KakaoLoginRequest: Encodable {
    let oauthToken: String // 카카오 계정의 oauthToken의 accessToken
    let deviceToken: String?
}
