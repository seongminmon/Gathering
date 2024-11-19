//
//  AuthRouter.swift
//  Gathering
//
//  Created by dopamint on 11/12/24.
//

import Foundation

import Alamofire

enum AuthRouter {
    case refreshToken(refreshToken: String)
}

extension AuthRouter: TargetType {
    
    var method: HTTPMethod {
        switch self {
        case .refreshToken:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .refreshToken:
            return "/auth/refresh"
        }
    }
    
    var headers: HTTPHeaders {
        switch self {
        case .refreshToken:
            return [
                Header.sesacKey.rawValue: APIAuth.key,
                Header.contentType.rawValue: Header.json.rawValue,
                Header.authorization.rawValue: UserDefaultsManager.accessToken,
                "RefreshToken": UserDefaultsManager.refreshToken
            ]
        }
    }
    
    var parameters: Parameters? {
        switch self {
        default:
            return nil
        }
    }
    
    var body: Data? {
        switch self {
        default:
            return nil
        }
    }
}
