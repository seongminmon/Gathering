//
//  WorkspaceInfoResponse.swift
//  Gathering
//
//  Created by 여성은 on 11/12/24.
//

import Foundation
// TODO: 이거 없어도 되나요?? 🤔
struct WorkspaceInfoResponse: Decodable {
    let workspace_id: String
    let name: String
    let description: String
    let coverImage: String
    let owner_id: String
    let createdAt: String
    let channels: [ChannelResponse]
    let workspaceMembers: [MemberResponse]
}
