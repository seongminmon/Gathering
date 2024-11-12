//
//  CounterFeature.swift
//  Gathering
//
//  Created by dopamint on 11/4/24.
//

import ComposableArchitecture
import Foundation

enum CancelID { case timer }

// 1.4 버전부터 매크로 지원, ReducerProtocol을 채택하게 해줌
@Reducer
struct CounterFeature {
    
    @ObservableState
    struct State {
        var count = 0
        var fact: String?
        var isLoading = false
        var isTimerRunning = false
    }
    
    enum Action/*: Equatable*/ { // Equatable은 채택해야 할까?
        case decrementButtonTapped // Action의 네이밍은 유저입장 UI에서의 동작으로 지정하는 것이 적절하대
        case incrementButtonTapped
        case factButtonTapped
        case factResponse(String)
        case timerTick
        case toggleTimerButtonTapped
    }
    var body: some ReducerOf<Self> { // typealias ReducerOf<R: Reducer> = Reducer<R.State, R.Action>
        Reduce { state, action in
            switch action {
            case .decrementButtonTapped:
                state.count -= 1
                state.fact = nil
                return .none
            case .incrementButtonTapped:
                state.count += 1
                state.fact = nil
                return .none
            case .factButtonTapped:
//                state.fact = nil
                state.isLoading = true
                
                return .run { [count = state.count] send in
                    let (data, _) = try await URLSession.shared
                        .data(from: URL(string: "http://numbersapi.com/\(count)")!)
                    let fact = String(decoding: data, as: UTF8.self)
                    //                    state.fact = fact //
                    await send(.factResponse(fact))
                }
            case .timerTick:
                    state.count += 1
                    state.fact = nil
                    return .none
                
            case .toggleTimerButtonTapped:
                state.isTimerRunning.toggle()
                if state.isTimerRunning {
                    return .run { send in
                        while true {
                            try await Task.sleep(for: .seconds(1))
                            await send(.timerTick)
                        }
                    }
                    .cancellable(id: CancelID.timer)
                } else {
                    return .cancel(id: CancelID.timer)
                }
                return .run { send in
                    while true {
                        try await Task.sleep(for: .seconds(1))
                        await send(.timerTick)
                    }
                }
            case let .factResponse(fact):
                state.fact = fact
                state.isLoading = false
                return .none
            }
        }
    }
}
