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

struct Dummy {
    static let channels: [Channel] = [
        Channel(name: "일반", unreadCount: nil),
        Channel(name: "스유 뽀개기", unreadCount: nil),
        Channel(name: "앱스토어 홍보", unreadCount: nil),
        Channel(name: "오픈라운지", unreadCount: 99),
        Channel(name: "TIL", unreadCount: nil)
    ]
    static let users: [DMUser] = [
        DMUser(profileImage: "bird", name: "캠퍼스지킴이", unreadCount: nil),
        DMUser(profileImage: "bird2", name: "Hue", unreadCount: 8),
        DMUser(profileImage: "bird3", name: "테스트 코드 짜는 새싹이", unreadCount: 1),
        DMUser(profileImage: "bird4", name: "Jack", unreadCount: nil)
    ]
}
