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
            GatheringNavigationStack { // "Direct Message" (네비게이션 타이틀)
                VStack {
                    TextField("닉네임 입력", text: $store.nickname)
                    
                    if store.chattingList.isEmpty {
                        emptyMemberView()
                    } else {
                        ScrollView(.horizontal) {
                            LazyHStack(spacing: 10) {
                                ForEach(store.userList, id: \.self) { item in
                                    userCell(user: item)
                                }
                            }
                            .frame(height: 100)
                            .padding(.horizontal, 20)
                        }
                        
                        ScrollView {
                            LazyVStack(spacing: 20, content: {
                                ForEach(store.chattingList, id: \.self) { item in
                                    Text("\(item)")
                                }
                            })
                        }
                    }
                    
                    Spacer()
                }
            }
        }
    }
    
    private func emptyMemberView() -> some View {
        VStack(spacing: 20) {
            Text("워크스페이스에 \n멤버가 없어요.")
                .font(Design.title1)
            Text("새로운 팀원을 초대해보세요.")
                .font(.body)
            Button("팀원 초대하기") {
                print("팀원 초대 버튼 탭")
                store.send(.profileButtonTap)
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
            ProfileImageView(imageName: user.profileImage, size: 44)
            Text(user.name)
                .font(Design.body)
                .frame(width: 44)
                .lineLimit(1)
        }
    }
    
    private func chattingCell(data: DMUser) {
        
    }
}

@Reducer
struct DMFeature {
    
    @ObservableState
    struct State {
        var userList = Dummy.users
        var chattingList = Dummy.users
        var nickname: String = ""
    }
    
    enum Action: BindableAction {
        case profileButtonTap
        case binding(BindingAction<State>)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .profileButtonTap:
                print("프로필 버튼 탭")
                return .none
                
            case .binding(\.nickname):
                return .none
                
            case .binding:
                return .none
            }
        }
    }
}
