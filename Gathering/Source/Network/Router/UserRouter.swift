//
//  UserRouter.swift
//  Gathering
//
//  Created by dopamint on 11/12/24.
//

import Foundation

import Alamofire

enum UserRouter {
    case join(body: JoinRequest) // 회원가입
    case emailValidation(body: EmailValidationRequest) // 이메일 중복확인
    case emailLogin(body: EmailLoginRequest)
    case kakaoLogin(body: KakaoLoginRequest)
    case appleLogin(body: AppleLoginRequest)
    case logout
    case saveDeviceToken(body: SaveDeviceTokenRequest) // FCM deviceToken 저장
    case fetchMyProfile // 내 프로필 정보 조회
    case editMyProfile(body: EditMyProfileRequest) // 내 프로필 정보 수정 (이미지 제외)
    case editMyProfileImage(body: EditMyProfileImageRequest) // 내 프로필 사진 수정
    case fetchUserProfile(userID: String) // 다른 유저 프로필 조회
}

extension UserRouter: TargetType {
    
    var method: HTTPMethod {
        switch self {
        case .logout,
                .fetchMyProfile,
                .fetchUserProfile:
            return .get
        case .join,
                .emailValidation,
                .emailLogin,
                .kakaoLogin,
                .appleLogin,
                .saveDeviceToken:
            return .post
        case .editMyProfile, 
                .editMyProfileImage:
            return .put
        }
    }
    
    var path: String {
        let basePath = "/users"
        
        switch self {
        case .join:
            return "\(basePath)/join"
        case .emailValidation:
            return "\(basePath)/validation/email"
        case .emailLogin:
            return "\(basePath)/login"
        case .kakaoLogin:
            return "\(basePath)/login/kakao"
        case .appleLogin:
            return "\(basePath)/login/apple"
        case .logout:
            return "\(basePath)/logout"
        case .saveDeviceToken:
            return "\(basePath)/deviceToken"
        case .fetchMyProfile:
            return "\(basePath)/me"
        case .editMyProfile:
            return "\(basePath)/me"
        case .editMyProfileImage:
            return "\(basePath)/me/image"
        case .fetchUserProfile(let userID):
            return "\(basePath)/\(userID)"
        }
    }
    
    var headers: HTTPHeaders {
        switch self {
        case .join,
                .emailValidation,
                .emailLogin,
                .kakaoLogin,
                .appleLogin,
                .saveDeviceToken,
                .logout,
                .fetchMyProfile,
                .fetchUserProfile,
                .editMyProfile:
            return [
                Header.sesacKey.rawValue: APIAuth.key,
                Header.contentType.rawValue: Header.json.rawValue,
                Header.authorization.rawValue: UserDefaultsManager.accessToken
            ]
        case .editMyProfileImage:
            return [
                Header.sesacKey.rawValue: APIAuth.key,
                Header.contentType.rawValue: Header.multiPart.rawValue,
                Header.authorization.rawValue: UserDefaultsManager.accessToken
            ]
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .fetchUserProfile(let userID):
            return ["userID": userID]
        default:
            return nil
        }
    }
    
    var body: Data? {
        switch self {
        case .join(let body):
            return try? JSONEncoder().encode(body)
        case .emailValidation(let body):
            return try? JSONEncoder().encode(body)
        case .emailLogin(let body):
            return try? JSONEncoder().encode(body)
        case .kakaoLogin(let body):
            return try? JSONEncoder().encode(body)
        case .appleLogin(let body):
            return try? JSONEncoder().encode(body)
        case .saveDeviceToken(let body):
            return try? JSONEncoder().encode(body)
        case .editMyProfile(let body):
            return try? JSONEncoder().encode(body)
        default:
            return nil
        }
    }
    
    var multipartData: [MultipartData]? {
        switch self {
        case .editMyProfileImage(let body):
            return [
                MultipartData(
                    data: body.image,
                    name: "image",
                    fileName: "image.jpg"
                )
            ]
        default:
            return nil
        }
    }
}
