//
//  TempModel.swift
//  Gathering
//
//  Created by dopamint on 11/5/24.
//

import Foundation

struct Channel: Identifiable, Hashable {
    let id: String
    let name: String
    let description: String?
    let coverImage: String?
    let owner_id: String
    let createdAt: String
    let channelMembers: [Member]?
}
