//
//  MyApp.swift
//  Gathering
//
//  Created by dopamint on 11/11/24.
//
//
import ComposableArchitecture
import SwiftUI

//
//@main
//struct MyApp: App {
//  static let store = Store(initialState: AppFeature.State()) {
//    AppFeature()
//  }
//  
//  var body: some Scene {
//    WindowGroup {
//      AppView(store: MyApp.store)
//    }
//  }
//}

@Reducer
struct RootFeature {
    
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

@Reducer
struct RedFeature {
    
    @ObservableState
    struct State {
        
    }
    
    enum Action {
        case clickBackButton
    }
    
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .clickBackButton:
                return .none
            }
        }
    }
}

@Reducer
struct BlueFeature {
    
    @ObservableState
    struct State {
        
    }
    
    enum Action {
        case clickBackButton
        case clickNextButton
    }
    
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .clickBackButton:
                return .none
            case .clickNextButton:
                return .none
            }
        }
    }
}

@Reducer
struct OrangeFeature {
    
    @Dependency(\.dismiss) var dismiss
    
    @ObservableState
    struct State {
        
    }
    
    enum Action {
        case clickBackButton
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .clickBackButton:
                return .run { _ in
                    await dismiss()
                }
            }
        }
    }
}

struct RootView1: View {
    
    @Perception.Bindable var store: StoreOf<RootFeature>
    
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            VStack {
                // Push 1
                NavigationLink(
                    state: RootFeature.Path.State.redFeature(RedFeature.State())
                ) {
                    Text("RedView Push 1 (Link)")
                        .frame(height: 30)
                }
                
                NavigationLink(
                    state: RootFeature.Path.State.blueFeature(BlueFeature.State())
                ) {
                    Text("BlueView Push 1 (Link)")
                        .frame(height: 30)
                }
                
                Spacer()
                    .frame(height:50)
                
                // Push 2
                Button("RedView Push 2 (append)") {
                    store.send(.clickRedButton)
                }
                .frame(height: 30)
                
                Button("BlueView Push 2 (append)") {
                    store.send(.clickBlueButton)
                }
                .frame(height: 30)
            }
            .navigationTitle("RootFeature")
            
        } destination: { store in
            switch store.case {
            case .redFeature(let redStore):
                RedView(store: redStore)
            case .blueFeature(let blueStore):
                BlueView(store: blueStore)
            case .orangeFeature(let orangeStore):
                OrangeView(store: orangeStore)
            }
        }
        
    }
}

struct RedView: View {
    
    var store: StoreOf<RedFeature>
    
    var body: some View {
        ZStack {
            Color.red
            
            VStack {
                Button("back") {
                    store.send(.clickBackButton)
                }.frame(height: 30)
                    .foregroundStyle(.black)
            }
            .navigationTitle("RedView")
        }
    }
}

struct BlueView: View {
    
    var store: StoreOf<BlueFeature>
    
    var body: some View {
        ZStack {
            Color.blue
            
            VStack {
                Button("back") {
                    store.send(.clickBackButton)
                }.frame(height: 30)
                    .foregroundStyle(.black)
                
                Button("Next") {
                    store.send(.clickNextButton)
                }.frame(height: 30)
                    .foregroundStyle(.black)
            }
            .navigationTitle("BlueView")
        }
    }
}


struct OrangeView: View {
    
    var store: StoreOf<OrangeFeature>
    
    var body: some View {
        ZStack {
            Color.orange
            VStack {
                Button("back") {
                    store.send(.clickBackButton)
                }.frame(height: 30)
                    .foregroundStyle(.black)
            }
            .navigationTitle("OrangeView")
        }
    }
}
