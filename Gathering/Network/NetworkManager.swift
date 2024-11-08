//
//  NetworkManager.swift
//  Gathering
//
//  Created by 김성민 on 11/7/24.
//

import Foundation
import Alamofire

struct ErrorResponse: Decodable, Error {
    let errorCode: String
}

final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    func request<Router: TargetType, ModelType: Decodable>(api: Router) async throws -> ModelType {
        let request = try api.asURLRequest()
        let response = await AF.request(request).serializingData().response
        let statusCode = response.response?.statusCode ?? 0
        
        switch statusCode {
        case 200:
            // 상태 코드가 200일 때 ModelType으로 디코딩
            do {
                let decodedData = try JSONDecoder().decode(
                    ModelType.self,
                    from: response.data ?? Data()
                )
                return decodedData
            } catch {
                throw error
            }
            
        case 400:
            // 상태 코드가 400일 때 ErrorResponse로 디코딩
            do {
                let errorData = try JSONDecoder().decode(
                    ErrorResponse.self,
                    from: response.data ?? Data()
                )
                throw errorData // ErrorResponse를 던져 오류로 처리
            } catch {
                throw error
            }
            
        default:
            // 그 외의 경우 일반 오류 처리 (서버 에러)
            throw AFError.responseValidationFailed(
                reason: .unacceptableStatusCode(code: statusCode)
            )
        }
    }
}
