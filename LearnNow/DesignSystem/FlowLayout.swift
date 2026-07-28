import SwiftUI

struct FlowLayout<Item: Hashable, Content: View>: View {
    let items: [Item]
    let content: (Item) -> Content

    var body: some View {
        WrappingRowLayout(spacing: 8) {
            ForEach(items, id: \.self) { item in
                content(item)
            }
        }
    }
}

private struct WrappingRowLayout: Layout {
    let spacing: CGFloat

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let idealSizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let naturalWidth = idealSizes.reduce(0) { width, size in
            width + size.width
        } + spacing * CGFloat(max(idealSizes.count - 1, 0))
        let availableWidth = proposal.width ?? naturalWidth
        let sizes = fittedSizes(
            for: subviews,
            idealSizes: idealSizes,
            availableWidth: availableWidth
        )

        return layoutSize(for: sizes, availableWidth: availableWidth)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let idealSizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let sizes = fittedSizes(
            for: subviews,
            idealSizes: idealSizes,
            availableWidth: bounds.width
        )
        var origin = bounds.origin
        var rowHeight: CGFloat = 0

        for (subview, size) in zip(subviews, sizes) {
            let proposedMaxX = origin.x + size.width

            if origin.x > bounds.minX, proposedMaxX > bounds.maxX {
                origin.x = bounds.minX
                origin.y += rowHeight + spacing
                rowHeight = 0
            }

            subview.place(
                at: origin,
                anchor: .topLeading,
                proposal: ProposedViewSize(size)
            )

            origin.x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }

    private func fittedSizes(
        for subviews: Subviews,
        idealSizes: [CGSize],
        availableWidth: CGFloat
    ) -> [CGSize] {
        zip(subviews, idealSizes).map { subview, idealSize in
            guard idealSize.width > availableWidth else {
                return idealSize
            }

            return subview.sizeThatFits(
                ProposedViewSize(width: availableWidth, height: nil)
            )
        }
    }

    private func layoutSize(for sizes: [CGSize], availableWidth: CGFloat) -> CGSize {
        var rowWidth: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalWidth: CGFloat = 0
        var totalHeight: CGFloat = 0

        for size in sizes {
            let nextWidth = rowWidth == 0
                ? size.width
                : rowWidth + spacing + size.width

            if rowWidth > 0, nextWidth > availableWidth {
                totalWidth = max(totalWidth, rowWidth)
                totalHeight += rowHeight + spacing
                rowWidth = size.width
                rowHeight = size.height
            } else {
                rowWidth = nextWidth
                rowHeight = max(rowHeight, size.height)
            }
        }

        totalWidth = max(totalWidth, rowWidth)
        totalHeight += rowHeight

        return CGSize(width: min(totalWidth, availableWidth), height: totalHeight)
    }
}
