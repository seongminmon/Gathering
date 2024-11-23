//
//  DMChattingView.swift
//  Gathering
//
//  Created by dopamint on 11/21/24.
//

import SwiftUI

import ComposableArchitecture

struct DMChattingView: View {
    @Perception.Bindable var store: StoreOf<DMChattingFeature>
    
    var body: some View {
        WithPerceptionTracking {
            Group {
                ChattingView()
            }
        }
    }
}
