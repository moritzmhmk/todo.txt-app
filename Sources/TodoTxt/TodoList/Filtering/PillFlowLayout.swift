import SwiftUI

/// A simple horizontal flow layout that wraps views to new lines.
struct PillFlowLayout: Layout {
    let spacing: CGFloat

    init(spacing: CGFloat = 6) {
        self.spacing = spacing
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        var width: CGFloat = 0
        var height: CGFloat = 0
        var rowHeight: CGFloat = 0

        let maxWidth = proposal.width ?? .infinity

        for subview in subviews {
            let subviewSize = subview.sizeThatFits(.unspecified)

            if width + subviewSize.width > maxWidth {
                // wrap to next line
                width = 0
                height += rowHeight + spacing
                rowHeight = 0
            }

            width += subviewSize.width + spacing
            rowHeight = max(rowHeight, subviewSize.height)
        }

        height += rowHeight

        return CGSize(width: maxWidth, height: height)
    }

    func placeSubviews(
        in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()
    ) {
        var x: CGFloat = bounds.minX
        var y: CGFloat = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let subviewSize = subview.sizeThatFits(.unspecified)

            if x + subviewSize.width > bounds.maxX {
                // wrap
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }

            subview.place(
                at: CGPoint(x: x, y: y),
                proposal: ProposedViewSize(width: subviewSize.width, height: subviewSize.height))
            x += subviewSize.width + spacing
            rowHeight = max(rowHeight, subviewSize.height)
        }
    }
}
