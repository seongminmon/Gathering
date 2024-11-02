//
//  GatheringApp.swift
//  Gathering
//
//  Created by 김성민 on 11/1/24.
//

import SwiftUI

import ComposableArchitecture

@main
struct GatheringApp: App {
    
    static let store = Store(initialState: CounterFeature.State()) {
        CounterFeature()
    }
    
    var body: some Scene {
        WindowGroup {
            CounterView(store: GatheringApp.store)
        }
    }
}
