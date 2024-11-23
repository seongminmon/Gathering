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
    // >> ✅ 워크스페이스 멤버 조회
    // ✅ 1. 유저 프로필 이미지
    // ✅ 2. 유저 닉네임
    
    // TODO: - DM 채팅방
    // >> ✅ DM 방 리스트 조회
    
    // 1. ✅ 상대방 프로필 이미지
    // 2. ✅ 상대방 닉네임
    // 3. 최근 메시지 내용
    // 4. 최근 메시지 날짜 / 오늘이라면 시간
    // 5. 안 읽은 메시지 갯수
    
    // >>> 최근 메시지를 가져오는 방법
    // dmRoomList가 있을 때
    // roomID들을 알 수 있음
    // for문을 돌면서 하나씩 해결해나가야 함
    
    // 1. Realm에 저장된 DMChat들을 roomID로 필터링
    // 하나의 방에 있는 [DMChat]을 구함
    // createdAt으로 오름차순 정렬
    // 가장 마지막 채팅이 내가 읽은 것 중에 최신채팅
    
    // 2. 그 날짜 기준으로 이후의 DM 채팅 내역 리스트 조회 API 호출
    // >>> 결과 배열의 count가 안 읽은 메시지 갯수
    // or 그 날짜 기준으로 unread API 호출해도 됨
    // 결과 정보들을 Realm에 추가로 저장
    
    // 3. realm의 마지막 요소가 바로 최근 채팅
    // >> 그 contents와 createdAt을 기준으로
    // 최근 메시지 내용과 최근 메시지 날짜를 구해내면 됨!
    
    // TODO: - 워크스페이스 멤버 초대
    // ✅ 1. 워크스페이스 EmptyView
    // ✅ 2. 워크스페이스 멤버 초대 뷰
    // ✅ 3. 워크스페이스 멤버 초대
    
    // TODO: - 간헐적으로 통신은 완료 되었는데 Loading 뷰가 사라지지 않는 현상
    
    @Perception.Bindable var store: StoreOf<DMFeature>
    
    var body: some View {
        WithPerceptionTracking {
            GatheringNavigationStack(
                gatheringImage: store.currentWorkspace?.coverImage,
                title: "Direct Message",
                profileImage: store.myProfile?.profileImage
            ) {
                VStack {
                    if store.isLoading {
                        ProgressView()
                    } else if store.workspaceMembers.isEmpty {
                        emptyMemberView()
                    } else {
                        // 워크 스페이스 멤버 리스트
                        ScrollView(.horizontal) {
                            LazyHStack(spacing: 10) {
                                ForEach(store.workspaceMembers, id: \.id) { item in
                                    userCell(user: item)
                                }
                            }
                            .frame(width: 80, height: 100)
                            .padding(.horizontal, 16)
                        }
                        
                        // DM 채팅방
                        ScrollView {
                            LazyVStack(spacing: 20) {
                                ForEach(store.dmRoomList, id: \.self) { item in
                                    dmCell(dm: item)
                                }
                            }
                        }
                        
                        Spacer()
                    }
                }
            }
            .task { store.send(.task) }
            .sheet(isPresented: $store.inviteMemberViewPresented) {
                inviteMemberView()
            }
        }
    }
    
    private func emptyMemberView() -> some View {
        VStack(spacing: 8) {
            Text("모임에 멤버가 없어요.")
                .font(Design.title1)
            Text("새로운 팀원을 초대해보세요.")
                .font(Design.body)
            Button {
                store.send(.inviteMemberSheetButtonTap)
            } label: {
                RoundedButton(
                    text: "팀원 초대하기",
                    foregroundColor: Design.white,
                    backgroundColor: Design.green
                )
            }
            .padding()
        }
    }
    
    private func userCell(user: Member) -> some View {
        VStack(spacing: 4) {
            ProfileImageView(urlString: user.profileImage ?? "", size: 44)
            Text(user.nickname)
                .font(Design.body)
                .frame(width: 44)
                .lineLimit(1)
        }
    }
    
    private func dmCell(dm: DMsRoom) -> some View {
        HStack(alignment: .top, spacing: 4) {
            ProfileImageView(urlString: dm.user.profileImage ?? "", size: 34)
            
            // 닉네임, 최근 DM 내용
            VStack(alignment: .leading, spacing: 4) {
                Text(dm.user.nickname)
                    .font(Design.body)
                
                // TODO: - 최신 DM 내용
                Text(dm.user.email)
                    .font(Design.body)
                    .foregroundStyle(Design.gray)
            }
            
            Spacer()
            
            // 닉네임, 최근 DM 내용
            VStack(alignment: .trailing, spacing: 4) {
                // TODO: - 최신 DM 날짜 or 시간
                Text("PM 11:23")
                    .font(Design.body)
                    .foregroundStyle(Design.gray)
                
                // TODO: - 안 읽은 갯수
                Text("\(10)")
                    .badge()
            }
        }
        .padding(.horizontal, 16)
    }
    
    private func inviteMemberView() -> some View {
        VStack {
            SheetHeaderView(title: "팀원 초대")
                .background(Design.white)
            ScrollView {
                // TODO: - first responder 만들기
                TextFieldWithTitle(
                    title: "이메일",
                    placeholder: "초대하려는 팀원의 이메일을 입력하세요.",
                    text: $store.email
                )
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            inviteButton()
                .padding([.horizontal, .bottom])
        }
        .background(Design.gray)
    }
    
    private func inviteButton() -> some View {
        Button {
            store.send(.inviteMemberButtonTap)
        } label: {
            RoundedButton(
                text: "초대 보내기",
                foregroundColor: Design.white,
                backgroundColor: Design.green
            )
        }
        .disabled(!store.inviteButtonValid)
    }
}
