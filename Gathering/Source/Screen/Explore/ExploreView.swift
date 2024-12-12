//
//  ExploreView.swift
//  Gathering
//
//  Created by dopamint on 11/20/24.
//

import SwiftUI

import ComposableArchitecture

struct ExploreView: View {
    
    let store: StoreOf<ExploreFeature>
    
    var body: some View {
        WithPerceptionTracking {
            Text("둘러보기 뷰")
        }
    }
}
