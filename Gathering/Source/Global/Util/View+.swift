//
//  View+.swift
//  Gathering
//
//  Created by 여성은 on 11/24/24.
//

import SwiftUI
extension View {
    // 키보드 숨기기 메서드
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil,
                                        from: nil,
                                        for: nil)
    }
    
    // 화면 너비 가져옴
    func getScreenWidth() -> CGFloat {
        return UIScreen.main.bounds.width
    }
    
}
