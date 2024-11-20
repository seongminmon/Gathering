//
//  NetworkManager.swift
//  Gathering
//
//  Created by 김성민 on 11/7/24.
//

import UIKit

import Alamofire

final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    // 공통 로직을 수행하는 내부 메서드
    private func performRequest<Router: TargetType>(api: Router) async throws -> Data? {
        let request = try api.asURLRequest()
        let response = await AF.request(request).serializingData().response
        let statusCode = response.response?.statusCode ?? 0
        
        switch statusCode {
        case 200:
            // 성공 시 데이터를 반환
            print("통신 성공")
            return response.data
            
        case 400, 500:
            // 상태 코드가 400 또는 500일 때 ErrorResponse로 디코딩
            do {
                let errorData = try JSONDecoder().decode(
                    ErrorResponse.self,
                    from: response.data ?? Data()
                )
                print("통신 에러 \(errorData.errorCode)")
                
                // 엑세스 토큰 만료일 경우
                if errorData.errorCode == APIError.accessTokenExpired.rawValue {
                    do {
                        // 토큰 갱신 통신
                        let result: Token = try await NetworkManager.shared.request(
                            api: AuthRouter.refreshToken(
                                refreshToken: UserDefaultsManager.refreshToken
                            )
                        )
                        // 엑세스 토큰 저장
                        UserDefaultsManager.refresh(result.accessToken)
                        // 기존 요청 재시도
                        return try await performRequest(api: api)
                    } catch {
                        print("토큰 갱신 에러")
                    }
                }
                throw errorData
            } catch {
                print("에러 모델 디코딩 실패")
                throw APIError.etc
            }
            
        default:
            print("알 수 없는 에러")
            throw APIError.etc
        }
    }
    
    /// 데이터가 필요한 요청
    func request<Router: TargetType, ModelType: Decodable>(api: Router) async throws -> ModelType {
        guard let data = try await performRequest(api: api) else {
            throw APIError.etc
        }
        
        do {
            return try JSONDecoder().decode(ModelType.self, from: data)
        } catch {
            print("모델 디코딩 실패")
            throw APIError.etc
        }
    }
    
    /// 응답 데이터가 필요 없는 요청
    func requestWithoutResponse<Router: TargetType>(api: Router) async throws {
        _ = try await performRequest(api: api)
    }
    
    /// 이미지 URL 통신 (메모리 캐시 적용)
    func requestImage(_ api: ImageRouter) async throws -> UIImage {
        let request = try api.asURLRequest()
        
        guard let url = request.url else {
            throw APIError.etc
        }
        
        // 캐시 확인
        if let cachedImage = ImageCache.shared.object(forKey: url as NSURL) {
            print("캐시 히트")
            return cachedImage
        }
        
        print("캐시 미스")
        guard let data = try await performRequest(api: api) else {
            throw APIError.etc
        }
        
        if let uiImage = UIImage(data: data) {
            print("캐시 저장")
            ImageCache.shared.setObject(uiImage, forKey: url as NSURL)
            return uiImage
        } else {
            throw APIError.etc
        }
    }
}
