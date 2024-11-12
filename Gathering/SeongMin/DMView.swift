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
            GatheringNavigationStack(content: {
                VStack {
                    // MARK: - tca bind test
                    TextField("닉네임 입력", text: $store.nickname)
                    
                    // MARK: - tca dependency network test
                    Button {
                        store.send(.networkButtonTap)
                    } label: {
                        StartActiveButton()
                    }
                    
                    // MARK: - toast test
                    Button {
                        store.send(.toastButtonTap)
                    } label: {
                        ContinueEmailButton()
                    }
                    
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
                                    chattingCell(data: item)
                                }
                            })
                        }
                    }
                    
                    Spacer()
                }
            }, gatheringImage: "bird", profileImage: "bird")  // "Direct Message" (네비게이션 타이틀)
               
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
    
    private func chattingCell(data: DMUser) -> some View {
        HStack(spacing: 4) {
            ProfileImageView(imageName: data.profileImage, size: 34)
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

@Reducer
struct DMFeature {
    
    @Dependency(\.storeClient) var storeClient
    
    @ObservableState
    struct State {
        var userList = Dummy.users
        var chattingList = Dummy.users
        var nickname: String = ""
        var itemReponse: [StoreItemResponse] = []
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case profileButtonTap
        case networkButtonTap
        case networkResponse([StoreItemResponse])
        case errorResponse(Error)
        case toastButtonTap
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .binding(\.nickname):
                print(state.nickname)
                return .none
                
            case .profileButtonTap:
                print("프로필 버튼 탭")
                return .none
                
            case .networkButtonTap:
                print("네트워크 버튼 탭")
                
                // 네트워크 비동기 작업을 별도 효과로 수행
                return .run { send in
                    do {
                        let result = try await storeClient.itemList()
                        await send(.networkResponse(result))
                    } catch {
                        print("네트워크 에러 발생: \(error)")
                        await send(.errorResponse(error))
                    }
                }
                
            case .networkResponse(let response):
                // 네트워크 응답 처리
                print(response)
                state.itemReponse = response
                return .none
                
            case .errorResponse(let error):
                print(error)
                return .none
                
            case .toastButtonTap:
                print("토스트 버튼 탭")
                let toast = Toast(title: "토스트 테스트 메시지입니다")
                NotificationCenter.default.post(
                    name: .showToast,
                    object: nil,
                    userInfo: [Notification.UserInfoKey.toast: toast]
                )
                return .none
            }
        }
    }
}
