//
//  ChattingFeature.swift
//  Gathering
//
//  Created by dopamint on 11/21/24.
//

import SwiftUI

import ComposableArchitecture

@Reducer
struct ChannelChattingFeature {
    
    @Reducer
    enum Path {
        case redFeature(RedFeature)
        case blueFeature(BlueFeature)
        case orangeFeature(OrangeFeature)
    }
    
    @ObservableState
    struct State {
        var path = StackState<Path.State>()
    }
    
    enum Action {
        case path(StackActionOf<Path>)
        case clickRedButton
        case clickBlueButton
    }
    
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            switch action {
                
            // 부모뷰에서 직접 push
            case .clickRedButton:
                state.path.append(.redFeature(RedFeature.State()))
                return .none
                
            case .clickBlueButton:
                state.path.append(.blueFeature(BlueFeature.State()))
                return .none
                
            // 자식 이벤트 받아서 push
            case .path(.element(id: _, action: .blueFeature(.clickNextButton))):
                state.path.append(.orangeFeature(OrangeFeature.State()))
                return .none
                
            // 자식 이벤트 받아서 pop
            case .path(.element(id: _, action: .redFeature(.clickBackButton))):
                _ = state.path.popLast()
                return .none
                
            case .path(.element(id: let id, action: .blueFeature(.clickBackButton))):
                state.path.pop(from: id)
                return .none
                
            // OrangeFeature에서 Dependency dismiss 으로 대체가능
//            case .path(.element(id: let id, action: .orangeFeature(.clickBackButton))):
//                state.path.pop(from: id)
//                return .none
                
            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
    
}
