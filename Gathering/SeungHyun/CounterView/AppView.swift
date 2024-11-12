//
//  AppView.swift
//  Gathering
//
//  Created by dopamint on 11/11/24.
//

import ComposableArchitecture
import SwiftUI

struct AppView: View {
  let store: StoreOf<AppFeature>
  
  var body: some View {
    TabView {
      CounterView(store: store.scope(state: \.tab1, action: \.tab1))
        .tabItem {
          Text("Counter 1")
        }
      
//        ContactsView(store: store.scope(state: \.tab2, action: \.tab2))
//        .tabItem {
//          Text("Counter 2")
//        }
    }
  }
}
