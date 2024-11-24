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
                ProfileImageView(urlString: "bird2", size: 300)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowBackground(Color.clear)
                
                Section {
                    HStack {
                        Text("닉네임")
                            .font(Design.bodyBold)
                        Spacer()
                        Text(store.nickname)
                            .foregroundColor(Design.textGray)
                            .font(Design.body)
                    }
                    
                    HStack {
                        Text("이메일")
                            .font(Design.bodyBold)
                        Spacer()
                        Text(store.email)
                            .foregroundColor(Design.textGray)
                            .font(Design.body)
                    }
                }
                
                if store.state.profileType == .me {
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
                title: store.state.profileType == .me ? "내 정보 수정" : "프로필",
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
