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
//    let unreadCount: Int?
}
struct DMUser: Identifiable, Hashable {
    let id = UUID()
    let profileImage: String
    let name: String
    let unreadCount: Int?
}

struct Dummy {
    static let channels: [Channel] = [
//        ChannelResponse(channel_id: "",
//                        name: "d",
//                        description: "",
//                        coverImage: "",
//                        owner_id: "",
//                        createdAt: "",
//                        channelMembers: [MemberResponse(user_id: "", email: "", nickname: "dd", profileImage: "")])
//        Channel(name: "스유 뽀개기"),
//        Channel(name: "앱스토어 홍보"),
//        Channel(name: "오픈라운지"),
//        Channel(name: "TIL")
    ]
    static let users: [DMUser] = [
        DMUser(profileImage: "bird", name: "캠퍼스지킴이", unreadCount: nil),
        DMUser(profileImage: "bird2", name: "Hue", unreadCount: 8),
        DMUser(profileImage: "bird3", name: "테스트 코드 짜는 새싹이", unreadCount: 1),
        DMUser(profileImage: "bird4", name: "Jack", unreadCount: nil)
    ]
}
