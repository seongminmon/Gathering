//
//  DMView.swift
//  Gathering
//
//  Created by 김성민 on 11/4/24.
//

import SwiftUI

import ComposableArchitecture

struct DMView: View {
    
    // TODO: - 네비게이션 바
    // ✅ 1. 워크 스페이스 이미지 불러오기
    // >> 내가 속한 워크스페이스 리스트 통신
    // >> coverImage
    
    // ✅ 2. 네비게이션 타이틀 DirectMessage 고정
    // ✅ 3. 내 프로필 이미지 불러오기
    
    // TODO: - 워크 스페이스 멤버
    // 1. 유저 프로필 이미지
    // 2. 유저 닉네임
    
    // TODO: - DM 채팅방
    // 1. 상대방 프로필 이미지
    // 2. 상대방 닉네임 
    // 3. 최근 메시지 내용
    // 4. 최근 메시지 날짜 / 오늘이라면 시간
    // 5. 안 읽은 메시지 갯수
    
    @Perception.Bindable var store: StoreOf<DMFeature>
    
    var body: some View {
        WithPerceptionTracking {
            GatheringNavigationStack(
                gatheringImage: store.currentWorkspace?.coverImage,
                title: "Direct Message",
                profileImage: store.myProfile?.profileImage
            ) {
                Text("DMView")
            }
            .task { store.send(.task) }
        }
    }
    
    private func emptyMemberView() -> some View {
        VStack(spacing: 20) {
            Text("워크스페이스에 \n멤버가 없어요.")
                .font(Design.title1)
            Text("새로운 팀원을 초대해보세요.")
                .font(.body)
            Button("팀원 초대하기") {
                store.send(.inviteMemberButtonTap)
            }
            .font(.title2)
            .foregroundStyle(.white)
            .frame(width: 269, height: 44)
            .background(.green)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
    
    private func userCell(user: DMUser) -> some View {
        VStack(spacing: 4) {
            ProfileImageView(urlString: user.profileImage, size: 44)
            Text(user.name)
                .font(Design.body)
                .frame(width: 44)
                .lineLimit(1)
        }
    }
    
    private func chattingCell(data: DMUser) -> some View {
        HStack(spacing: 4) {
            ProfileImageView(urlString: data.profileImage, size: 34)
            VStack(spacing: 4) {
                Text(data.name)
                    .font(Design.body)
                Text(data.name)
                    .font(Design.body)
                    .foregroundStyle(Design.gray)
            }
            Spacer()
            VStack(spacing: 4) {
                Text("PM 11:23")
                    .font(Design.body)
                    .foregroundStyle(Design.gray)
                EmptyView().badge(10)
            }
        }
        .padding(.horizontal, 16)
    }
}
