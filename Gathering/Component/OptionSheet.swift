//
//  OptionSheet.swift
//  Gathering
//
//  Created by dopamint on 11/6/24.
//

import SwiftUI

struct OptionSheet: View {
    let options: [SheetOption]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(options) { option in
                    Button(action: {
                        option.action()
                        dismiss()
                    }) {
                        HStack {
                            Text(option.title)
                                .foregroundColor(.blue)
                            Spacer()
                            if option.showChevron {
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Design.gray)
                            }
                        }
                    }
                }
            }
            .listStyle(.inset)
        }
    }
}
struct SheetOption: Identifiable {
    let id = UUID()
    let title: String
    let action: () -> Void
    let showChevron: Bool
    
    init(
        title: String,
        showChevron: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.showChevron = showChevron
        self.action = action
    }
}
