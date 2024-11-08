//
//  NavigationModifier.swift
//  Gathering
//
//  Created by dopamint on 11/6/24.
//

import SwiftUI

struct ToolbarConfig {
    let title: String
    let leftItem: BarButton?
    let rightItem: BarButton?
    
    struct BarButton {
        let icon: String
        let action: () -> Void
    }
}

struct ToolbarModifier: ViewModifier {
    let config: ToolbarConfig
    
    func body(content: Content) -> some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // 왼쪽 아이템
                if let leftItem = config.leftItem {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: leftItem.action) {
                            Image(systemName: leftItem.icon)
                                .foregroundColor(.black)
                        }
                    }
                }
                
                // 중앙 타이틀
                ToolbarItem(placement: .principal) {
                    Text(config.title)
                        .font(.headline)
                        .foregroundColor(.black)
                }
                
                // 오른쪽 아이템
                if let rightItem = config.rightItem {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: rightItem.action) {
                            Image(systemName: rightItem.icon)
                                .foregroundColor(.black)
                        }
                    }
                }
            }
    }
}

extension View {
    func customToolbar(
        title: String,
        leftItem: ToolbarConfig.BarButton? = nil,
        rightItem: ToolbarConfig.BarButton? = nil
    ) -> some View {
        let config = ToolbarConfig(
            title: title,
            leftItem: leftItem,
            rightItem: rightItem
        )
        return modifier(ToolbarModifier(config: config))
    }
}
