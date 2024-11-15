//
//  AuthInterceptor.swift
//  Gathering
//
//  Created by 김성민 on 11/12/24.
//

import Foundation

import Alamofire

// MARK: - 엑세스 토큰 갱신
final class AuthInterceptor: RequestInterceptor {
    static let shared = AuthInterceptor()
    private init() {}
    
    // Request가 전송되기 전
    func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping (Result<URLRequest, Error>) -> Void
    ) {
        guard urlRequest.url?.absoluteString.hasPrefix(APIAuth.baseURL) == true else {
            completion(.success(urlRequest))
            return
        }
        
        print("Adapt - 헤더 세팅")
        var urlRequest = urlRequest
        urlRequest.setValue(
            UserDefaultsManager.accessToken,
            forHTTPHeaderField: Header.authorization.rawValue
        )
        completion(.success(urlRequest))
    }
    
    // Request가 전송된 후
    func retry(
        _ request: Request,
        for session: Session,
        dueTo error: Error,
        completion: @escaping (RetryResult) -> Void
    ) {
        // MARK: - 에러코드 400이고 "E05" 일때만 토큰 갱신 진행
        
        // 400 상태 코드 확인
        guard let response = request.task?.response as? HTTPURLResponse,
              response.statusCode == 400 else {
            return completion(.doNotRetryWithError(error))
        }
        
//        do {
//            let errorResponse = try JSONDecoder().decode(
//                ErrorResponse.self,
//                from: response.data ?? Data()
//            )
//        } catch {
//            completion(.doNotRetryWithError(error))
//        }
        
        // TODO: - 토큰 갱신 API 호출
        // TODO: - 갱신 실패 -> 로그인 화면으로 전환
        
    }
}
