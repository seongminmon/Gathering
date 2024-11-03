//
//  SeongMinView.swift
//  Gathering
//
//  Created by 김성민 on 11/1/24.
//

import SwiftUI

import ComposableArchitecture

struct CounterView: View {
    let store: StoreOf<CounterFeature>
    
    var body: some View {
        WithPerceptionTracking {
            Form {
                Section {
                    Text("\(store.count)")
                    Button("Decrement") { store.send(.decrementButtonTapped) }
                    Button("Increment") { store.send(.incrementButtonTapped) }
                }
                
                Section {
                    Button("Number fact") { store.send(.numberFactButtonTapped) }
                }
                
                if let fact = store.numberFact {
                    Text(fact)
                }
            }
        }
    }
}

@Reducer
struct CounterFeature {
    
    @Dependency(\.numberFact) var numberFact
    
    @ObservableState
    struct State {
        var count = 0
        var numberFact: String?
    }
    
    enum Action {
        case decrementButtonTapped
        case incrementButtonTapped
        case numberFactButtonTapped
        case numberFactResponse(String)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .decrementButtonTapped:
                state.count -= 1
                return .none
                
            case .incrementButtonTapped:
                state.count += 1
                return .none
                
            case .numberFactButtonTapped:
                return .run { [count = state.count] send in
                    
                    let fact = try await numberFact.fetch(count)
                    await send(.numberFactResponse(fact))
                }
                
            case let .numberFactResponse(fact):
                state.numberFact = fact
                return .none
            }
        }
    }
}

struct NumberFactClient {
    var fetch: (Int) async throws -> String
}

extension NumberFactClient: DependencyKey {
    static let liveValue = Self(
        fetch: { number in
            let (data, _) = try await URLSession.shared
                .data(from: URL(string: "http://numbersapi.com/\(number)")!
                )
            return String(data: data, encoding: .utf8) ?? "nil"
        }
    )
}

extension DependencyValues {
    var numberFact: NumberFactClient {
        get { self[NumberFactClient.self] }
        set { self[NumberFactClient.self] = newValue }
    }
}
