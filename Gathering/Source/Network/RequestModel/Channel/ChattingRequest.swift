//
//  ChattingRequest.swift
//  Gathering
//
//  Created by 김성민 on 11/9/24.
//

import Foundation

struct ChattingRequest: Encodable {
    let content: String?
    let files: [Data]?
}
