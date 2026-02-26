//
//  AdaptiveNavigationView.swift
//  ToDoList
//
//  Copyright © 2024 RanduSoft. All rights reserved.
//

import SwiftUI

struct AdaptiveNavigationView: View {
    var body: some View {
        ContentTabView()
    }
}

#Preview {
    AdaptiveNavigationView()
        .modelContainer(DatabaseConfiguration.makePreviewContainer())
}
