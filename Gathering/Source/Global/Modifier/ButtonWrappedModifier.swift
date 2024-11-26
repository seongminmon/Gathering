//
//  ButtonWrappedModifier.swift
//  Gathering
//
//  Created by 여성은 on 11/26/24.
//

import SwiftUI

private struct ButtonWrapper: ViewModifier {
    
    let action: () -> Void
    
    func body(content: Content) -> some View {
        Button(action: action,
               label: { content })
    }
}

extension View {
    func wrapToButton(_ action: @escaping () -> Void) -> some View {
        modifier(ButtonWrapper(action: action))
    }
}
