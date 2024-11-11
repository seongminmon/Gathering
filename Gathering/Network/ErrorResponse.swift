//
//  ErrorResponse.swift
//  Gathering
//
//  Created by 김성민 on 11/11/24.
//

import Foundation

struct ErrorResponse: Decodable, Error {
    let errorCode: String
}
