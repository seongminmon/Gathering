//
//  DMsRoom.swift
//  Gathering
//
//  Created by 김성민 on 11/21/24.
//

import Foundation

struct DMsRoom: Hashable, Identifiable {
    let id: String
    let createdAt: String
    let user: Member
}
