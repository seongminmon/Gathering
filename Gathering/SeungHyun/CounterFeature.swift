//
//  CounterFeature.swift
//  Gathering
//
//  Created by dopamint on 11/2/24.
//

//import ComposableArchitecture
//
//@Reducer
//struct CounterFeature {
//    @ObservableState
//    struct State: Equatable {
//        var count = 0
//    }
//    
//    enum Action/*: Equatable*/ { // Equatable은 채택해야 할까?
//        case decrementButtonTapped // Action의 네이밍은 유저입장 UI에서의 동작으로 지정하는 것이 적절하대
//        case incrementButtonTapped
//    }
//    var body: some ReducerOf<Self> { // typealias ReducerOf<R: Reducer> = Reducer<R.State, R.Action>
//        Reduce { state, action in
//            switch action {
//            case .decrementButtonTapped:
//                state.count -= 1
//                return .none
//            case .incrementButtonTapped:
//                state.count += 1
//                return .none
//            }
//        }
//    }
//}
