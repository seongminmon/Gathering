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
                // 프로필 이미지 섹션
                LoadedImageView(urlString: store.profileImage, size: 250)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowBackground(Color.clear)
                
                // me 타입일 때만 보여줄 세싹 코인 섹션
                if store.profileType == .me {
                    Section {
                        HStack {
                            Text("내 새싹 코인")
                                .font(Design.bodyBold)
                            Text("\(store.sesacCoin)")
                                .foregroundStyle(Design.black)
                            Spacer()
                            Button("충전하기") {
                                store.send(.chargeSesacCoinTap)
                            }
                            .foregroundStyle(Design.black)
                        }
                    }
                }
                
                // 기본 정보 섹션
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
                                Text("응급한 고래밥")
                                    .foregroundStyle(Design.textGray)
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
                
                // me 타입일 때만 보여줄 로그아웃 섹션
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
                    dismiss()
                }
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
