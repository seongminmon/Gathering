//
//  UnreadCountResponse.swift
//  Gathering
//
//  Created by 김성민 on 11/11/24.
//

import Foundation

struct UnreadChannelResponse: Decodable {
    let channel_id: String
    let name: String
    let count: Int
}
