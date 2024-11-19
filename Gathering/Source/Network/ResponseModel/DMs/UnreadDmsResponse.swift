//
//  UnreadDmsResponse.swift
//  Gathering
//
//  Created by 여성은 on 11/12/24.
//

import Foundation

struct UnreadDmsResponse: Decodable {
    let room_id: String
    let count: Int
}
