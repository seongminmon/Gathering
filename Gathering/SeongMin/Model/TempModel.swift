//
//  TempModel.swift
//  Gathering
//
//  Created by dopamint on 11/5/24.
//

import Foundation

struct Channel: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let unreadCount: Int?
}
struct DMUser: Identifiable {
    let id = UUID()
    let profileImage: String
    let name: String
    let unreadCount: Int?
}
