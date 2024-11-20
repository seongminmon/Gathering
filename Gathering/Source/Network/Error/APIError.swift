//
//  APIError.swift
//  Gathering
//
//  Created by 김성민 on 11/11/24.
//

import Foundation

enum APIError: String, Error {
    // 접근 권한
    case unauthorizedAccess = "E01"
    // 알 수 없는 라우터 경로
    case unknownRoute = "E97"
    // 엑세스 토큰 만료
    case accessTokenExpired = "E05"
    // 인증 실패
    case authenticationFailed = "E02"
    // 알 수 없는 계정
    case unknownAccount = "E03"
    // 과호출
    case tooManyRequests = "E98"
    // 서버 오류
    case serverError = "E99"
    // 리프레시 토큰 만료
    case refreshTokenExpired = "E06"
    // 기타
    case etc
}

extension APIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .unauthorizedAccess:
            return "접근 권한"
        case .unknownRoute:
            return "알 수 없는 라우터 경로"
        case .accessTokenExpired:
            return "엑세스 토큰 만료"
        case .authenticationFailed:
            return "인증 실패"
        case .unknownAccount:
            return "알 수 없는 계정"
        case .tooManyRequests:
            return "과호출"
        case .serverError:
            return "서버 오류"
        case .refreshTokenExpired:
            return "리프레시 토큰 만료"
        case .etc:
            return "기타 오류"
        }
    }
}
