//
//  ProfileView.swift
//  Gathering
//
//  Created by 김성민 on 11/21/24.
//

import SwiftUI

import ComposableArchitecture

struct ProfileView: View {
    @Perception.Bindable var store: StoreOf<ProfileFeature>
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        WithPerceptionTracking {
            List {
                CustomPhotoPicker(
                    selectedImages: $store.selectedImage,
                    maxSelectedCount: 1
                ) {
                    if let images = store.selectedImage, let image = images.last {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 250, height: 250, alignment: .center)
                            .clipShape(RoundedRectangle(cornerRadius: 250 * 0.2))
                            .shadow(color: Design.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    } else {
                        LoadedImageView(urlString: store.profileImage, size: 250)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .listRowBackground(Color.clear)
                    }
                }
                .listRowBackground(Color.clear)
                
                if store.profileType == .me {
                    
                    Button(action: {
                        store.send(.deleteProfileImage)
                    }, label: {
                        Text("프로필사진 초기화")
                            .font(Design.caption)
                            .foregroundStyle(Design.darkGray)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Design.darkGray, lineWidth: 1)
                            )
                    })
                    .frame(width: .infinity, alignment: .center)
                    .padding(.vertical, 8)
                    .listRowBackground(Color.clear)
                }
                
                Section {
                    HStack {
                        Text("닉네임")
                            .font(Design.bodyBold)
                        Spacer()
                        Text(store.nickname)
                            .foregroundStyle(Design.textGray)
                            .font(Design.body)
                    }
                    
                    if store.profileType == .me {
                        Button {
                            store.send(.phoneNumberTap)
                        } label: {
                            HStack {
                                Text("연락처")
                                    .font(Design.bodyBold)
                                Spacer()
                                Text("010-0000-0000")
                                    .foregroundColor(Design.textGray)
                                Image(.chevronRight)
                                    .resizable()
                                    .frame(width: 15, height: 15)
                            }
                        }
                        .foregroundStyle(.black)
                    }
                    
                    HStack {
                        Text("이메일")
                            .font(Design.bodyBold)
                        Spacer()
                        Text(store.email)
                            .foregroundStyle(Design.textGray)
                            .font(Design.body)
                    }
                }
                
                if store.profileType == .me {
                    Section {
                        Button("로그아웃", role: .destructive) {
                            store.send(.logoutButtonTap)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationBarBackButtonHidden()
            .customToolbar(
                title: store.profileType == .me ? "내 정보 수정" : "프로필",
                leftItem: .init(icon: .chevronLeft) {
                    store.send(.saveButtonTap)
                    dismiss()
                },
                rightItem: store.profileType == .me ?
                    .init(text: "저장", isAbled: !store.isProfileChanged) {
                        store.send(.saveButtonTap)
                    } : nil
            )
        }
        .customAlert(
            isPresented: $store.showAlert,
            title: "로그아웃",
            message: "로그아웃 하시겠습니까?",
            primaryButton: .init(
                title: "확인",
                action: {
                    store.send(.logoutConfirm)
                }
            ),
            secondaryButton: .init(
                title: "취소",
                action: {
                    store.send(.logoutCancel)
                }
            )
        )
    }
}
