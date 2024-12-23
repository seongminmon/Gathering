//
//  NetworkManager.swift
//  Gathering
//
//  Created by 김성민 on 11/7/24.
//

import UIKit

import Alamofire
import ComposableArchitecture

final class NetworkManager {
    @Dependency(\.dbClient) var dbClient
    
    static let shared = NetworkManager()
    private init() {}
    
    /// 데이터가 필요한 요청
    func request<Router: TargetType, ModelType: Decodable>(
        api: Router
    ) async throws -> ModelType {
        let data = api.multipartData == nil ?
                   try await performRequest(api: api) :
                   try await performMultipartRequest(api: api)
        return try handleResponse(data: data, api: api)
    }
    
    /// 응답 데이터가 필요 없는 요청
    func requestWithoutResponse<Router: TargetType>(api: Router) async throws {
        _ = try await performRequest(api: api)
    }
    
    /// MultipartFormData 요청
    private func requestWithMultipart<Router: TargetType, ModelType: Decodable>(
        api: Router
    ) async throws -> ModelType {
        let data = try await performMultipartRequest(api: api)
        return try handleResponse(data: data, api: api)
    }
    
    /// 이미지 URL 통신 (캐시 적용)
    func requestImage(_ api: ImageRouter) async throws -> UIImage {
        let request = try api.asURLRequest()
        
        guard let url = request.url else {
            throw APIError.etc
        }
        
        // 1. 메모리 캐시 확인
        if let cachedImage = ImageCache.shared.object(forKey: url as NSURL) {
            return cachedImage
        }
        
        // 2. 디스크 캐시 확인
        if let cachedImage = ImageFileManager.shared.loadImageFile(filename: api.path) {
            ImageCache.shared.setObject(cachedImage, forKey: url as NSURL)
            return cachedImage
        }
        
        // 3. 네트워크 통신
        guard let data = try await performRequest(api: api),
              let uiImage = UIImage(data: data) else {
            throw APIError.etc
        }
        ImageCache.shared.setObject(uiImage, forKey: url as NSURL)
        return uiImage
    }
    
    private func handleResponse<T: Decodable>(
        data: Data?,
        api: any TargetType
    ) throws -> T {
        guard let data = data else {
            throw APIError.etc
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("\(api) 모델 디코딩 실패")
            throw APIError.etc
        }
    }
    
    private func handleError(
        response: Data?,
        api: any TargetType
    ) async throws -> Error {
        do {
            let errorData = try JSONDecoder().decode(
                ErrorResponse.self,
                from: response ?? Data()
            )
            print("\(api) 에러 \(errorData.errorCode)")
            
            if errorData.errorCode == APIError.accessTokenExpired.rawValue {
                return try await handleTokenRefresh(errorData: errorData)
            }
            return errorData
        } catch {
            print("\(api) 에러 모델 디코딩 실패")
            return APIError.etc
        }
    }
    
    private func handleTokenRefresh(errorData: ErrorResponse) async throws -> Error {
        do {
            let result: Token = try await request(
                api: AuthRouter.refreshToken(
                    refreshToken: UserDefaultsManager.refreshToken
                )
            )
            UserDefaultsManager.refresh(result.accessToken)
            return errorData
        } catch {
            print("토큰 갱신 에러")
            // 온보딩 화면 이동
            Notification.changeRoot(.fail)
            UserDefaultsManager.removeAll()
            try dbClient.removeAll()
            ImageFileManager.shared.deleteAllImages()
            return error
        }
    }
    
    private func performRequest<Router: TargetType>(api: Router) async throws -> Data? {
        let request = try api.asURLRequest()
        let response = await AF.request(request).serializingData().response
        return try await handleStatusCode(response: response, api: api)
    }
    
    private func performMultipartRequest<Router: TargetType>(
        api: Router
    ) async throws -> Data? {
        let request = try api.asURLRequest()
        let response = await AF.upload(
            multipartFormData: { multipartFormData in
                // 일반 파라미터 추가
                if let parameters = api.parameters {
                    for (key, value) in parameters {
                        let data = Data("\(value)".utf8)
                        multipartFormData.append(data, withName: key)
                    }
                }
                
                // 멀티파트 데이터 추가
                if let multipartDatas = api.multipartData {
                    for item in multipartDatas {
                        multipartFormData.append(
                            item.data,
                            withName: item.name,
                            fileName: item.fileName,
                            mimeType: item.mimeType
                        )
                    }
                }
            },
            with: request
        ).serializingData().response
        
        return try await handleStatusCode(response: response, api: api)
    }
    
    private func handleStatusCode(
        response: AFDataResponse<Data>,
        api: any TargetType
    ) async throws -> Data? {
        let statusCode = response.response?.statusCode ?? 0
        
        switch statusCode {
        case 200:
            print("\(api) 성공")
            return response.data
            
        case 400, 500:
            let error = try await handleError(response: response.data, api: api)
            
            // 토큰 만료 에러인 경우 요청 재시도
            if let errorResponse = error as? ErrorResponse,
               errorResponse.errorCode == APIError.accessTokenExpired.rawValue {
                if api.multipartData != nil {
                    return try await performMultipartRequest(api: api)
                } else {
                    return try await performRequest(api: api)
                }
            }
            throw error
            
        default:
            print("\(api) 알 수 없는 에러")
            throw APIError.etc
        }
    }
}
