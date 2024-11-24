//
//  MultipartData.swift
//  Gathering
//
//  Created by 김성민 on 11/24/24.
//

import Foundation

struct MultipartData {
    let data: Data
    let name: String
    var fileName: String?
    let mimeType = "image/jpeg"
}
