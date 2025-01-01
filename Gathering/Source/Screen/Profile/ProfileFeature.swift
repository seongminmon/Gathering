//
//  ProfileFeature.swift
//  Gathering
//
//  Created by dopamint on 11/22/24.
//

import SwiftUI

import ComposableArchitecture
import PhotosUI

@Reducer
struct ProfileFeature {
    
    @Dependency(\.userClient) var userClient
    @Dependency(\.dbClient) var dbClient
    
    enum ProfileType {
        case me
        case otherUser
    }
    
    @ObservableState
    struct State {
        var showAlert = false
        let profileType: ProfileFeature.ProfileType
        var nickname: String
        var email: String
        var profileImage: String

        var isProfileChanged: Bool {
            return selectedImage != nil || profileImage.isEmpty
        }
        //        var selectedPhotos: [PhotosPickerItem] = []  // <-- 여기에 추가
        var selectedImage: [UIImage]? = []
        
        init(profileType: ProfileFeature.ProfileType,
             nickname: String = "",
             email: String = "",
             profileImage: String = "") {
            self.profileType = profileType
            self.nickname = nickname
            self.email = email
            self.profileImage = profileImage
        }
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case logoutButtonTap
        case logoutConfirm
        case logoutCancel
        // 새로 추가할 액션들
        case chargeSesacCoinTap
        case phoneNumberTap
        
        case saveButtonTap
        case imageChanged
        case deleteProfileImage
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .logoutButtonTap:
                state.showAlert = true
                return .none
                
            case .logoutConfirm:
                state.showAlert = false
                Notification.changeRoot(.fail)
                UserDefaultsManager.removeAll()
                do {
                    try dbClient.removeAll()
                } catch {}
                ImageFileManager.shared.deleteAllImages()
                return .none
                
            case .logoutCancel:
                state.showAlert = false
                return .none
                
            case .chargeSesacCoinTap:
                // 충전 로직 구현
                return .none
                
            case .phoneNumberTap:
                // 전화번호 수정 로직 구현
                return .none
                
            case .saveButtonTap:
                return .run { [state = state] send in
                    do {
                        print("changeProfileImage 됨")
                        guard let data = state.selectedImage?.last?.jpegData(
                            compressionQuality: 0.5
                        ) else {
                            print("이미지 데이터가 엄서요")
                            return
                        }
                        _ = try await userClient.editMyProfileImage(
                            EditMyProfileImageRequest(image: data)
                        )
                        Notification.postToast(title: "프로필 사진이 변경되었습니다.")
                        await send(.imageChanged)
                    } catch {
                        print("Error!!!")
                    }
                }
            case .imageChanged:
                return .none
            case .deleteProfileImage:
                state.selectedImage?.removeAll()
                return .none
            }
        }
    }
}
