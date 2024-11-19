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
                throw error
            }
            
        default:
            print("알 수 없는 에러")
            throw AFError.responseValidationFailed(
                reason: .unacceptableStatusCode(code: statusCode)
            )
        }
    }
    
    // 데이터가 필요한 요청
    func request<Router: TargetType, ModelType: Decodable>(api: Router) async throws -> ModelType {
        guard let data = try await performRequest(api: api) else {
            throw AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength)
        }
        
        do {
            return try JSONDecoder().decode(ModelType.self, from: data)
        } catch {
            print("모델 디코딩 실패")
            throw error
        }
    }
    
    // 응답 데이터가 필요 없는 요청
    func requestWithoutResponse<Router: TargetType>(api: Router) async throws {
        _ = try await performRequest(api: api)
    }
    
    // 이미지 URL 통신 (캐시 적용)
//    func loadImage(_ urlString: String) async throws -> UIImage {
//        guard let imageURL = URL(string: APIAuth.baseURL + "v1" + urlString) else {
//            print("URL 없음")
//            throw
//        }
//        
//        // 캐시 확인
//        if let cachedImage = ImageCache.shared.object(forKey: imageURL as NSURL) {
//            print("캐시 히트")
//            return cachedImage
//        }
//        
//        print("캐시 미스")
//        
//        // 캐시에 없으면 네트워크 요청
//        var request = URLRequest(url: imageURL)
//        request.setValue(APIAuth.key, forHTTPHeaderField: Header.sesacKey.rawValue)
//        request.setValue(
//            UserDefaultsManager.accessToken,
//            forHTTPHeaderField: Header.authorization.rawValue
//        )
//        
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let data = data, let downloadedImage = UIImage(data: data) {
//                print("이미지 다운로드 성공")
//                DispatchQueue.main.async {
//                    // 다운로드한 이미지 캐싱
//                    ImageCache.shared.setObject(downloadedImage, forKey: imageURL as NSURL)
//                    self.uiImage = downloadedImage
//                    self.isLoading = false
//                }
//            } else {
//                print("이미지 다운로드 실패")
//                DispatchQueue.main.async {
//                    self.isLoading = false
//                }
//            }
//        }
//        .resume()
//    }
}
