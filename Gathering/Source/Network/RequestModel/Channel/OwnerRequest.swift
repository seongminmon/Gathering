//
//  OwnerRequest.swift
//  Gathering
//
//  Created by 김성민 on 11/9/24.
//

import Foundation

struct OwnerRequest: Encodable {
    let ownerID: String
    
    enum CodingKeys: String, CodingKey {
        case ownerID = "owner_id"
    }
}
