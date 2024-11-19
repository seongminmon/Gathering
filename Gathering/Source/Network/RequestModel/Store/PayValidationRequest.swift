//
//  PayValidationRequest.swift
//  Gathering
//
//  Created by 김성민 on 11/7/24.
//

import Foundation

struct PayValidationRequest: Encodable {
    let impUID: String
    let merchantUID: String
    
    enum CodingKeys: String, CodingKey {
        case impUID = "imp_uid"
        case merchantUID = "merchant_uid"
    }
}
