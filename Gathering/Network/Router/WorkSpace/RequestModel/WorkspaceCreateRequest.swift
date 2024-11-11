//
//  WorkspaceCreateRequest.swift
//  Gathering
//
//  Created by 여성은 on 11/12/24.
//

import Foundation

struct WorkspaceCreateRequest: Encodable {
    let name: String
    let description: String? = nil
    let image: Data
    
}
