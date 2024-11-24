//
//  ChannelRequest.swift
//  Gathering
//
//  Created by 김성민 on 11/8/24.
//

import Foundation

struct ChannelRequest: Encodable {
    let name: String
    let description: String?
    let image: Data?
}
