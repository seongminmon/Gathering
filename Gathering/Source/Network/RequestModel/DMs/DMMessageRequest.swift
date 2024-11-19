//
//  DMRequest.swift
//  Gathering
//
//  Created by 여성은 on 11/12/24.
//

import Foundation

struct DMMessageRequest: Encodable {
    let content: String?
    let files: [Data]?
}
