//
//  ChannelChattingView.swift
//  Gathering
//
//  Created by dopamint on 11/21/24.
//

import SwiftUI

import ComposableArchitecture

struct ChannelChattingView: View {
    @Perception.Bindable var store: StoreOf<ChannelChattingFeature>
    
    var body: some View {
        WithPerceptionTracking {
            Group {
                ChattingView()
            }
        }
    }
}
