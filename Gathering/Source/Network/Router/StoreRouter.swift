//
//  StoreRouter.swift
//  Gathering
//
//  Created by 김성민 on 11/7/24.
//

import Foundation

import Alamofire

enum StoreRouter {
    // 새싹 코인 결제 검증
    case payValidation(body: PayValidationRequest)
    // 새싹 코인 스토어 아이템 리스트
    case itemList
}

extension StoreRouter: TargetType {
   
    var method: HTTPMethod {
        switch self {
        case .payValidation:
            return .post
        case .itemList:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .payValidation:
            return "/store/pay/validation"
        case .itemList:
            return "/store/item/list"
        }
    }
    
    var headers: HTTPHeaders {
        switch self {
        case .payValidation, .itemList:
            return [
                Header.sesacKey.rawValue: APIAuth.key,
                Header.contentType.rawValue: Header.json.rawValue,
                Header.authorization.rawValue: UserDefaultsManager.accessToken
            ]
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .payValidation, .itemList:
            return nil
        }
    }
    
    var body: Data? {
        switch self {
        case .payValidation(let body):
            return try? JSONEncoder().encode(body)
        case .itemList:
            return nil
        }
    }
}
