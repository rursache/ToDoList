//
//  CommentRowView.swift
//  ToDoList
//
//  Copyright © 2024 RanduSoft. All rights reserved.
//

import SwiftUI

struct CommentRowView: View {
    let comment: CommentModel
    @State private var showFullImage = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(comment.date.formatted(style: .comment))
                .font(.caption)
                .foregroundStyle(.secondary)

            if let imageData = comment.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .onTapGesture {
                        showFullImage = true
                    }
                    .fullScreenCover(isPresented: $showFullImage) {
                        FullImageView(image: uiImage)
                    }
            } else {
                Text(comment.content)
            }
        }
        .padding(.vertical, 4)
    }
}

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
