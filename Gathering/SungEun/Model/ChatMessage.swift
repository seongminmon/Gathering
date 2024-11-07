//
//  ChatMessage.swift
//  Gathering
//
//  Created by 여성은 on 11/7/24.
//

import Foundation
import UIKit

// 메시지 모델 정의
struct ChatMessage: Identifiable {
    var id = UUID()
    let name: String
    let text: String
    let images: [UIImage]
    let date = Date()
    let isMine: Bool
    let profile: String?
}