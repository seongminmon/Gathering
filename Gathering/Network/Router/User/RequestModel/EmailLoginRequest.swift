//
//  EmailLoginRequest.swift
//  Gathering
//
//  Created by dopamint on 11/12/24.
//

import Foundation

struct EmailLoginRequest: Encodable {
    let email: String
    let password: String
    let deviceToken: String?
}
