//
//  ChatMessage.swift
//  Gathering
//
//  Created by 여성은 on 11/7/24.
//

import Foundation

// 메시지 모델 정의
struct ChattingPresentModel: Identifiable {
    var id: String
    let user: Member
    let name: String
    let text: String?
    let imageNames: [String]
    let date: String
    let isMine: Bool
    let profile: String?
}
