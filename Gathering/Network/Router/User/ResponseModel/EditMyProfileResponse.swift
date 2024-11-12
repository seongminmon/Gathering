//
//  EditMyProfileResponse.swift
//  Gathering
//
//  Created by dopamint on 11/12/24.
//

import Foundation

struct EditMyProfileResponse: Decodable {
    let userID: String
    let email: String
    let nickname: String
    let profilImage: String?
    let phone: String?
    let provider: String?
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case email
        case nickname
        case profilImage
        case phone
        case provider
        case createdAt
    }
}
