//
//  ToastModifier.swift
//  Gathering
//
//  Created by 김성민 on 11/12/24.
//

import SwiftUI

struct ToastModifier: ViewModifier {
    
    @State var toast: Toast?
    @State private var workItem: DispatchWorkItem?
    
    init(toast: Toast? = nil) {
        _toast = State(initialValue: toast)
    }
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(
                ZStack {
                    mainToastView()
                        .offset(y: -30)
                        .zIndex(1)
                }.animation(.spring(), value: toast)
            )
            .onChange(of: toast) { value in
                showToast()
            }
    }
    
    @ViewBuilder
    func mainToastView() -> some View {
        if let toast = toast {
            VStack {
                Spacer()
                ToastView(title: toast.title)
            }
            .transition(.move(edge: .bottom))
        }
    }
    
    private func showToast() {
        guard let toast = toast else { return }
        
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        if toast.duration > 0 {
            workItem?.cancel()
            
            let task = DispatchWorkItem {
                dismissToast()
            }
            
            workItem = task
            DispatchQueue.main.asyncAfter(deadline: .now() + toast.duration, execute: task)
        }
    }
    
    private func dismissToast() {
        withAnimation {
            toast = nil
        }
        workItem?.cancel()
        workItem = nil
    }
}
