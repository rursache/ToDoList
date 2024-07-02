//
//  RSQueryView
//
//  Created by Radu Ursache - RanduSoft
//  Version: 1.0.0
//

import SwiftUI
import SwiftData

/// A SwiftUI view that manages and displays content based on a query to a persistent data store.
///
/// This generic view uses SwiftData to perform real-time queries against a persistent model specified by `Model`.
/// It dynamically generates views of type `Content` based on the query's results.
///
/// - Parameters:
///   - type: The type of `PersistentModel` to query.
///   - sort: An array of `SortDescriptor` to specify the sort order of the query results.
///   - content: A view builder that creates views from the fetched data.
///   - filter: An optional closure that defines a `Predicate` to filter the query results.
///
@available(swift 5.9)
@available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
public struct RSQueryView<Model: PersistentModel, Content: View>: View {
    @Query private var query: [Model]
    private var content: ([Model]) -> (Content)
    
    public init(for type: Model.Type, sort: [SortDescriptor<Model>] = [], @ViewBuilder content: @escaping ([Model]) -> Content, filter: (() -> (Predicate<Model>))? = nil) {
        _query = Query(filter: filter?(), sort: sort)
        self.content = content
    }
    
    public var body: some View {
        content(query)
    }
}
