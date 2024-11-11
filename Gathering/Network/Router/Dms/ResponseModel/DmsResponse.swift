//
//  DmsResponse.swift
//  Gathering
//
//  Created by 여성은 on 11/12/24.
//

import Foundation

typealias Dms = [DmsResponse]

struct DmsResponse: Decodable {
    let dm_id: String
    let room_id: String
    let content: String?
    let creatAt: String
    let files: [String]?
    let user: MemberResponse
}

