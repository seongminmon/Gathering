//
//  CustomDisclosure.swift
//  Gathering
//
//  Created by dopamint on 11/5/24.
//

import SwiftUI

struct CustomDisclosureGroup<Content: View>: View {
    let content: Content
    let label: String
    @Binding var isExpanded: Bool
    
    init(label: String, isExpanded: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self.label = label
        self._isExpanded = isExpanded
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Button {
                withAnimation {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Text(label)
                        .font(Design.title2)
                    Spacer()
                    Image(.chevronRight)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .animation(.easeIn, value: isExpanded)
                }
            }
            if isExpanded {
                content
            }
        }
    }
}
