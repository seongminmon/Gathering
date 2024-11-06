//
//  SeongMinView.swift
//  Gathering
//
//  Created by 김성민 on 11/1/24.
//

import SwiftUI

import ComposableArchitecture

//struct CounterView: View {
//    let store: StoreOf<CounterFeature>
//    
//    var body: some View {
//        WithPerceptionTracking {
//            Form {
//                Button(store.isTimerRunning ? "Stop timer" : "Start timer") {
//                    store.send(.toggleTimerButtonTapped)
//                }
//                
//                Section {
//                    Text("\(store.count)")
//                    Button("Decrement") { store.send(.decrementButtonTapped) }
//                    Button("Increment") { store.send(.incrementButtonTapped) }
//                }
//                
//                Section {
//                    Button("Number fact") { store.send(.factButtonTapped) }
//                }
//                
//                if store.isLoading {
//                    ProgressView()
//                } else if let fact = store.fact {
//                    Text(fact)
//                }
//            }
//        }
//    }
//    
//}
//
//@Reducer
//struct CounterFeature {
//    
//    @Dependency(\.continuousClock) var timer
//    @Dependency(\.dismiss) var dismiss
//    @Dependency(\.userClient) var userClient
//    
//    @ObservableState
//    struct State {
//        var count = 0
//        var fact: String?
//        var isLoading = false
//        var isTimerRunning = false
//        var showAlert = false
//    }
//    
//    enum Action {
//        case decrementButtonTapped
//        case incrementButtonTapped
//        case factButtonTapped
//        case factResponse(String)
//        case toggleTimerButtonTapped
//        case timerTick
//    }
//    
//    enum CancelID {
//        case timer
//    }
//    
//    var body: some ReducerOf<Self> {
//        Reduce { state, action in
//            switch action {
//            case .decrementButtonTapped:
//                state.count -= 1
//                return .none
//                
//            case .incrementButtonTapped:
//                state.count += 1
//                return .none
//                
//            case .factButtonTapped:
//                state.fact = nil
//                state.isLoading = true
//                return .run { [count = state.count] send in
//                    let fact = try await self.userClient.login(count)
//                    await send(.factResponse(fact))
//                }
//                
//            case let .factResponse(fact):
//                state.fact = fact
//                state.isLoading = false
//                return .none
//                
//            case .toggleTimerButtonTapped:
//                state.isTimerRunning.toggle()
//                
//                if state.isTimerRunning {
//                    return .run { send in
//                        while true {
//                            try await Task.sleep(for: .seconds(1))
//                            await send(.timerTick)
//                        }
//                    }
//                    .cancellable(id: CancelID.timer)
//                } else {
//                    return .cancel(id: CancelID.timer)
//                }
//                
//            case .timerTick:
//                state.count += 1
//                state.fact = nil
//                return .none
//            }
//        }
//    }
//}
//
//// MARK: - Dependency
//struct UserClient {
//    var login: (Int) async throws -> String
//    var signUp: (Int) async throws -> String
//    var fetch1: (Int) async throws -> String
//    var fetch2: (Int) async throws -> String
//}
//
//extension UserClient: DependencyKey {
//    static let liveValue: UserClient = UserClient(
//        login: { number in
//            let (data, _) = try await URLSession.shared.data(
//                from: URL(string: "http://numbersapi.com/\(number)")!
//            )
//            return String(data: data, encoding: .utf8) ?? "nil"
//        },
//        signUp: { number in
//            let (data, _) = try await URLSession.shared.data(
//                from: URL(string: "http://numbersapi.com/\(number)")!
//            )
//            return String(data: data, encoding: .utf8) ?? "nil"
//        },
//        fetch1: { number in
//            let (data, _) = try await URLSession.shared.data(
//                from: URL(string: "http://numbersapi.com/\(number)")!
//            )
//            return String(data: data, encoding: .utf8) ?? "nil"
//        },
//        fetch2: { number in
//            let (data, _) = try await URLSession.shared.data(
//                from: URL(string: "http://numbersapi.com/\(number)")!
//            )
//            return String(data: data, encoding: .utf8) ?? "nil"
//        }
//    )
//}
//
//extension DependencyValues {
//    var userClient: UserClient {
//        get { self[UserClient.self] }
//        set { self[UserClient.self] = newValue }
//    }
//}
