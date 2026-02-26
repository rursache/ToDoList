//
//  FullImageView.swift
//  ToDoList
//
//  Copyright © 2024 RanduSoft. All rights reserved.
//

import SwiftUI

struct FullImageView: View {
    let image: UIImage
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(String(localized: "done", defaultValue: "Done")) {
                            dismiss()
                        }
                    }
                }
        }
    }
}

#Preview {
    FullImageView(image: UIImage(systemName: "photo")!)
}
