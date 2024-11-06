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
                    
                    Text("시작하기")
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .foregroundStyle(.white)
                        .background(.green)
                        .padding()
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    TextField("닉네임 입력", text: $store.nickname)
                    
                    if store.list.isEmpty {
                        emptyMemberView()
                    } else {
                        ScrollView(.horizontal) {
                            LazyHStack(spacing: 10) {
                                userCell()
                            }
                        }
                        ScrollView {
                            LazyVStack(spacing: 20, content: {
                                ForEach(store.list, id: \.self) { item in
                                    Text("\(item)")
                                }
                            })
                        }
                    }
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
    
    private func userCell() -> some View {
        VStack(spacing: 4) {
            Image(systemName: "star")
                .profileImageStyle()
                .frame(width: 44, height: 44)
            Text("asdf")
        }
    }
}

extension Image {
    func profileImageStyle() -> some View {
        self
            .resizable()
            .frame(width: 32, height: 32)
            .background(.gray)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

@Reducer
struct DMFeature {
    
    @ObservableState
    struct State {
        var list: [String] = ["a", "b", "c"]
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
                state.list.append("asdfasdf")
                return .none
                
            case .binding(\.nickname):
                return .none
                
            case .binding:
                return .none
            }
        }
    }
}
