//
//  CommentsView.swift
//  ToDoList
//
//  Copyright © 2024 RanduSoft. All rights reserved.
//

import SwiftUI
import PhotosUI

struct CommentsView: View {
    @Bindable var task: TaskModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var newCommentText = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var editingComment: CommentModel?
    @State private var editText = ""

    private var activeComments: [CommentModel] {
        task.activeComments.sorted { $0.date < $1.date }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if activeComments.isEmpty {
                    ContentUnavailableView(
                        String(localized: "noComments", defaultValue: "No comments"),
                        systemImage: "bubble.left",
                        description: Text(String(localized: "addCommentPrompt", defaultValue: "Add a comment below"))
                    )
                    .frame(maxHeight: .infinity)
                } else {
                    List {
                        ForEach(activeComments) { comment in
                            CommentRowView(comment: comment)
                                .onTapGesture {
                                    if comment.imageData == nil {
                                        editingComment = comment
                                        editText = comment.content
                                    }
                                }
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        comment.isDeleted = true
                                    } label: {
                                        Label(String(localized: "delete", defaultValue: "Delete"), systemImage: "trash")
                                    }
                                }
                        }
                    }
                }

                Divider()

                HStack(spacing: 12) {
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        Image(systemName: "photo")
                            .font(.title3)
                    }

                    TextField(String(localized: "addComment", defaultValue: "Add comment..."), text: $newCommentText)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit { addTextComment() }

                    Button {
                        addTextComment()
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                    }
                    .disabled(newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding()
            }
            .navigationTitle(String(localized: "comments", defaultValue: "Comments"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "done", defaultValue: "Done")) {
                        dismiss()
                    }
                }
            }
            .alert(String(localized: "editComment", defaultValue: "Edit Comment"), isPresented: Binding(
                get: { editingComment != nil },
                set: { if !$0 { editingComment = nil } }
            )) {
                TextField(String(localized: "comment", defaultValue: "Comment"), text: $editText)
                Button(String(localized: "save", defaultValue: "Save")) {
                    if let comment = editingComment {
                        comment.content = editText
                    }
                    editingComment = nil
                }
                Button(String(localized: "cancel", defaultValue: "Cancel"), role: .cancel) {
                    editingComment = nil
                }
            }
            .onChange(of: selectedPhoto) { _, newValue in
                Task {
                    await loadPhoto(newValue)
                }
            }
        }
    }

    private func addTextComment() {
        let trimmed = newCommentText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let comment = CommentModel()
        comment.content = trimmed
        comment.task = task
        modelContext.insert(comment)
        newCommentText = ""
    }

    private func loadPhoto(_ item: PhotosPickerItem?) async {
        guard let item else { return }
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        guard let uiImage = UIImage(data: data) else { return }
        let compressed = uiImage.jpegData(compressionQuality: 0.7)

        await MainActor.run {
            let comment = CommentModel()
            comment.imageData = compressed
            comment.content = String(localized: "imageComment", defaultValue: "Image")
            comment.task = task
            modelContext.insert(comment)
            selectedPhoto = nil
        }
    }
}

#Preview {
    CommentsView(task: TaskModel.sampleTasks.first!)
        .modelContainer(DatabaseConfiguration.makePreviewContainer())
}
