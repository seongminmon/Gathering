//
//  JoinRequest.swift
//  Gathering
//
//  Created by dopamint on 11/12/24.
//

import Foundation

struct JoinRequest: Encodable {
    let email: String
    let password: String // 최소 8자 하나 이상의 대,소문자 및 숫자, 특수문자
    let nickname: String // 1 ~ 30자 제한
    let phone: String?
    let deviceToken: String?
}
