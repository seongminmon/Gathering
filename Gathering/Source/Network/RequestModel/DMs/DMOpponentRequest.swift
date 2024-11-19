//
//  DMOpponentRequest.swift
//  Gathering
//
//  Created by 여성은 on 11/12/24.
//

import Foundation

struct DMOpponentRequest: Encodable {
    let opponentID: String
    
    enum CodingKeys: String, CodingKey {
        case opponentID = "opponent_id"
    }
}
