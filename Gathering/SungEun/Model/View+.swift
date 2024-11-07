//
//  View+.swift
//  Gathering
//
//  Created by 여성은 on 11/7/24.
//

import SwiftUI

extension View {
    // 키보드 숨기기 메서드
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
