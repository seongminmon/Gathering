//
//  NetworkManager.swift
//  Gathering
//
//  Created by 김성민 on 11/7/24.
//

import Foundation

import Alamofire

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
                print("통신 성공")
                return decodedData
            } catch {
                print("모델 디코딩 실패")
                throw error
            }
            
        case 400, 500:
            // 상태 코드가 400 또는 500일 때 ErrorResponse로 디코딩
            do {
                let errorData = try JSONDecoder().decode(
                    ErrorResponse.self,
                    from: response.data ?? Data()
                )
                print("통신 에러 \(errorData.errorCode)")
                throw errorData
            } catch {
                print("에러 모델 디코딩 실패")
                throw error
            }
            
        default:
            // 그 외의 경우 일반 오류 처리
            print("알 수 없는 에러")
            throw AFError.responseValidationFailed(
                reason: .unacceptableStatusCode(code: statusCode)
            )
        }
    }
}
