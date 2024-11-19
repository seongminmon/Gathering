//
//  ImageRouter.swift
//  Gathering
//
//  Created by 김성민 on 11/19/24.
//

import Foundation

import Alamofire

enum ImageRouter {
    case fetchImage(path: String)
}

extension ImageRouter: TargetType {
    
    var method: HTTPMethod {
        switch self {
        case .fetchImage:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .fetchImage(let path):
            return path
        }
    }
    
    var headers: HTTPHeaders {
        switch self {
        case .fetchImage:
            return [
                Header.sesacKey.rawValue: APIAuth.key,
                Header.contentType.rawValue: Header.json.rawValue,
                Header.authorization.rawValue: UserDefaultsManager.accessToken
            ]
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .fetchImage:
            return nil
        }
    }
    
    var body: Data? {
        switch self {
        case .fetchImage:
            return nil
        }
    }
}
