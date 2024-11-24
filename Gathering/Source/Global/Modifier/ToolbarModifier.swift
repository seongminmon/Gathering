//
//  ToolbarModifier.swift
//  Gathering
//
//  Created by dopamint on 11/6/24.
//

import SwiftUI

struct ToolbarConfig {
    let title: String
    let leftItem: BarButton?
    let rightItem: BarButton?
}

extension ToolbarConfig {
    struct BarButton {
        let icon: ImageResource
        let action: () -> Void
    }
}

// MARK: - ToolbarModifier
struct ToolbarModifier: ViewModifier {
    let config: ToolbarConfig
    
    func body(content: Content) -> some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        // 왼쪽 아이템
        if let leftItem = config.leftItem {
            ToolbarItem(placement: .navigationBarLeading) {
                makeBarButton(from: leftItem)
            }
        }
        
        // 중앙 타이틀
        ToolbarItem(placement: .principal) {
            Text(config.title)
                .font(Design.title2)
                .foregroundColor(Design.black)
        }
        
        // 오른쪽 아이템
        if let rightItem = config.rightItem {
            ToolbarItem(placement: .navigationBarTrailing) {
                makeBarButton(from: rightItem)
            }
        }
    }
    private func makeBarButton(from item: ToolbarConfig.BarButton) -> some View {
        Button(action: item.action) {
            Image(item.icon)
                .foregroundColor(Design.black)
        }
    }
}

// MARK: - View Extension
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
