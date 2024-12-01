//
//  DMView.swift
//  Gathering
//
//  Created by 김성민 on 11/4/24.
//

import SwiftUI

import ComposableArchitecture

struct DMView: View {
    
    @Perception.Bindable var store: StoreOf<DMFeature>
    
    var body: some View {
        WithPerceptionTracking {
            NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
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
                                ForEach(store.dmRoomList, id: \.id) { dmRoom in
                                    let lastChatting = store.dmChattings[dmRoom]?.last
                                    let unreadResponse = store.dmUnreads[dmRoom]
                                    dmCell(
                                        dm: dmRoom,
                                        lastChatting: lastChatting,
                                        unreadCount: unreadResponse
                                    )
                                }
                            }
                        }
                        
                        Spacer()
                    }
                }
                .asGatheringNavigationModifier(
                    gatheringImage: store.currentWorkspace?.coverImage ?? "",
                    title: "Direct Message",
                    myProfile: store.myProfile
                )
                .task { store.send(.task) }
                .sheet(isPresented: $store.inviteMemberViewPresented) {
                    inviteMemberView()
                }
            } destination: { store in
                switch store.case {
                case .profile(let store):
                    ProfileView(store: store)
                case .dmChatting(let store):
                    DMChattingView(store: store)
                }
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
        Button {
            store.send(.userCellTap(user))
        } label: {
            VStack(spacing: 4) {
                ProfileImageView(urlString: user.profileImage ?? "", size: 44)
                Text(user.nickname)
                    .font(Design.body)
                    .frame(width: 44)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
    }
    
    private func dmCell(
        dm: DMsRoom,
        lastChatting: DMsResponse?,
        unreadCount: UnreadDMsResponse?
    ) -> some View {
        Button {
            store.send(.dmCellTap(dm))
        } label: {
            HStack(alignment: .top, spacing: 4) {
                ProfileImageView(urlString: dm.user.profileImage ?? "", size: 34)
                
                // 닉네임, 최근 DM 내용
                VStack(alignment: .leading, spacing: 4) {
                    Text(dm.user.nickname)
                        .font(Design.body)
                    
                    Text(lastChatting?.content ?? "내용 없음")
                        .font(Design.body)
                        .foregroundStyle(Design.darkGray)
                }
                
                Spacer()
                
                // 최신 DM 날짜, 시간, 안 읽은 개수
                VStack(alignment: .trailing, spacing: 4) {
                    let date = lastChatting?.createdAt.createdAtToDate()
                    let dateString = date?.isToday ?? true ?
                    date?.toString(.todayChat) :
                    date?.toString(.pastChatUntilDay)
                    
                    Text(dateString ?? "날짜 없음")
                        .font(Design.body)
                        .foregroundStyle(Design.darkGray)
                    
                    Text("\(unreadCount?.count ?? 0)")
                        .badge()
                        .opacity(unreadCount?.count ?? 0 <= 0 ? 0 : 1)
                }
            }
            .padding(.horizontal, 16)
        }
        .buttonStyle(.plain)
    }
    
    private func inviteMemberView() -> some View {
        VStack {
            SheetHeaderView(title: "팀원 초대")
                .background(Design.white)
            ScrollView {
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
                backgroundColor: store.inviteButtonValid ? Design.green : Design.darkGray
            )
        }
        .disabled(!store.inviteButtonValid)
    }
}
