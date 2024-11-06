//
//  Router.swift
//  Gathering
//
//  Created by dopamint on 11/6/24.
//

import Foundation
import Alamofire

enum Router {

}

extension Router: TargetType {
   
    var method: HTTPMethod {
        switch self {

            }
        
    }
    
    var path: String {
        switch self {

        }
    }
    
    var headers: HTTPHeaders {
        var headers: HTTPHeaders = [Header.sesacKey.rawValue: APIAuth.key]
        switch self {

        }
        
    }
    
    var parameters: Parameters? {
        switch self {

        }
    }
    var body: Data? {
        switch self {
            
        }
    }
}

