//
//  DMFeature.swift
//  Gathering
//
//  Created by 김성민 on 11/16/24.
//

import Foundation

import ComposableArchitecture

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
                return .none
                
            case .networkButtonTap:
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
                Notification.postToast(title: "토스트 테스트 메시지입니다")
                return .none
            }
        }
    }
}
