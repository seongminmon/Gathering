//
//  UserClient.swift
//  Gathering
//
//  Created by dopamint on 11/12/24.
//

import Foundation

import ComposableArchitecture

struct UserClient {
    var join: (JoinRequest) async throws -> JoinLoginResponse
    var emailValidation: (EmailValidationRequest) async throws -> JoinLoginResponse
    var emailLogin: (EmailLoginRequest) async throws -> JoinLoginResponse
    var kakaoLogin: (KakaoLoginRequest) async throws -> JoinLoginResponse
    var appleLogin: (AppleLoginRequest) async throws -> JoinLoginResponse
    var logout: () async throws -> Void
    var saveDeviceToken: (SaveDeviceTokenRequest) async throws -> Void
    var fetchMyProfile: () async throws -> MyProfileResponse
    var editMyProfile: (EditMyProfileRequest) async throws -> EditMyProfileResponse
    var editMyProfileImage: (EditMyProfileImageRequest) async throws -> EditMyProfileResponse
    var fetchUserProfile: (String) async throws -> MemberResponse
}

extension UserClient: DependencyKey {
    static let liveValue = UserClient(
        join: { body in
            return try await NetworkManager.shared.request(
                api: UserRouter.join(body: body)
            )
        },
        emailValidation: { body in
            return try await NetworkManager.shared.request(
                api: UserRouter.emailValidation(body: body)
            )
        },
        emailLogin: { body in
            return try await NetworkManager.shared.request(
                api: UserRouter.emailLogin(body: body)
            )
        },
        kakaoLogin: { body in
            return try await NetworkManager.shared.request(
                api: UserRouter.kakaoLogin(body: body)
            )
        },
        appleLogin: { body in
            return try await NetworkManager.shared.request(
                api: UserRouter.appleLogin(body: body)
            )
        },
        logout: { 
            return try await NetworkManager.shared.requestWithoutResponse(
            api: UserRouter.logout
            )
        },
        saveDeviceToken: { body in
            return try await NetworkManager.shared.requestWithoutResponse(
                api: UserRouter.saveDeviceToken(body: body)
            )
        },
        fetchMyProfile: {
            return try await NetworkManager.shared.request(
                api: UserRouter.fetchMyProfile
            )
        },
        editMyProfile: { body in
            return try await NetworkManager.shared.request(
                api: UserRouter.editMyProfile(body: body)
            )
        },
        editMyProfileImage: { body in
            return try await NetworkManager.shared.request(
                api: UserRouter.editMyProfileImage(body: body)
            )
        },
        fetchUserProfile: { userID in
            return try await NetworkManager.shared.request(
                api: UserRouter.fetchUserProfile(userID: userID)
            )
        }
    )
}

extension DependencyValues {
    var userClient: UserClient {
        get { self[UserClient.self] }
        set { self[UserClient.self] = newValue }
    }
}

