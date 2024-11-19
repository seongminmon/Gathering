//
//  AppleLoginRequest.swift
//  Gathering
//
//  Created by dopamint on 11/12/24.
//

import Foundation

struct AppleLoginRequest: Encodable {
    let idToken: String // 애플 계정의 identityToken
    let nickname: String // 계정 닉네임(1-30자 제한 및 최초 애플 로그인(회원가입) 시 필수값)
    let deviceToken: String?
}
