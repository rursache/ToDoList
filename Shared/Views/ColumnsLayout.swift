//
//  ColumnsLayout.swift
//  ToDoList
//
//  Copyright © 2026 RanduSoft. All rights reserved.
//

import SwiftUI

struct ColumnsLayout: Layout {
    static let columnCount = 2

    var columns = ColumnsLayout.columnCount

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.replacingUnspecifiedDimensions().width
        let height = rowHeights(for: subviews, columnWidth: width / CGFloat(columns)).reduce(0, +)
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let columnWidth = bounds.width / CGFloat(columns)
        var y = bounds.minY

        for (row, height) in rowHeights(for: subviews, columnWidth: columnWidth).enumerated() {
            for column in 0..<columns {
                let index = row * columns + column
                guard subviews.indices.contains(index) else { break }
                subviews[index].place(
                    at: CGPoint(x: bounds.minX + CGFloat(column) * columnWidth, y: y),
                    proposal: ProposedViewSize(width: columnWidth, height: height)
                )
            }
            y += height
        }
    }

    private func rowHeights(for subviews: Subviews, columnWidth: CGFloat) -> [CGFloat] {
        stride(from: 0, to: subviews.count, by: columns).map { start in
            subviews[start..<min(start + columns, subviews.count)]
                .map { $0.sizeThatFits(ProposedViewSize(width: columnWidth, height: nil)).height }
                .max() ?? 0
        }
    }
}

extension EdgeInsets {
    static let columnCell = EdgeInsets(top: 14.5, leading: 20, bottom: 14.5, trailing: 20)
}

struct ColumnsScrollMargins: ViewModifier {
    static let minimumMargin: CGFloat = 20

    @State private var safeAreaInsets = EdgeInsets()

    func body(content: Content) -> some View {
        content
            .contentMargins(.leading, max(Self.minimumMargin - safeAreaInsets.leading, 0), for: .scrollContent)
            .contentMargins(.trailing, max(Self.minimumMargin - safeAreaInsets.trailing, 0), for: .scrollContent)
            .onGeometryChange(for: EdgeInsets.self) { $0.safeAreaInsets } action: { safeAreaInsets = $0 }
    }
}

extension View {
    func columnsScrollMargins() -> some View {
        modifier(ColumnsScrollMargins())
    }

    func columnsPanel() -> some View {
        background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 26))
    }

    func columnCell(position: Int, count: Int, separatorLeading: CGFloat) -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(Color(.secondarySystemGroupedBackground))
            .overlay(alignment: .bottom) {
                if position + ColumnsLayout.columnCount < count {
                    Divider()
                        .padding(.leading, separatorLeading)
                        .padding(.trailing, EdgeInsets.columnCell.trailing)
                }
            }
    }
}

struct ColumnCellButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color(.systemGray4) : Color.clear)
    }
}
