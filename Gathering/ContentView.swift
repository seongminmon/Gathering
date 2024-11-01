//
//  ContentView.swift
//  Gathering
//
//  Created by 김성민 on 11/1/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text(APIAuth.baseURL)
            Text(APIAuth.key)
        }
        .padding()
    }
}
