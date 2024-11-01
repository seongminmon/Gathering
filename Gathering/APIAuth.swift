//
//  APIAuth.swift
//  Gathering
//
//  Created by 김성민 on 11/1/24.
//

import Foundation

enum APIAuth {
    static let baseURL = Bundle.main.object(
        forInfoDictionaryKey: "BaseURL"
    ) as? String ?? "baseURL 없음"
    static let key = Bundle.main.object(forInfoDictionaryKey: "APIKey") as? String ?? "APIKey 없음"
}
