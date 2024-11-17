//
//  ToastWindowManager.swift
//  Gathering
//
//  Created by 김성민 on 11/12/24.
//

import SwiftUI

// MARK: - window 최상단에 토스트 메시지 띄우기
final class ToastWindowManager {
    static let shared = ToastWindowManager()
    private init() {}
    
    func showToast(toast: Toast?) {
        print(#function, "\(toast?.title ?? "토스트 타이틀 없음")")
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        let rootView = EmptyView()
            .modifier(ToastModifier(toast: toast))
        let hostingController = UIHostingController(rootView: rootView)
        hostingController.view.backgroundColor = .clear
        hostingController.view.frame = window.bounds
        hostingController.view.isUserInteractionEnabled = false
        
        window.addSubview(hostingController.view)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            UIView.animate(withDuration: 0.5, animations: {
                hostingController.view.alpha = 0
            }) { _ in
                hostingController.view.removeFromSuperview()
            }
        }
    }
}
