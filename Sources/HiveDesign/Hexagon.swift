import SwiftUI

/// A flat-topped hexagon, the Hive apps' shape (their icons, HiveScore's status lights).
public nonisolated struct Hexagon: Shape {
    public init() {}

    public func path(in r: CGRect) -> Path {
        let w = r.width
        return Path { p in
            p.move(to: CGPoint(x: r.minX + w * 0.25, y: r.minY))
            p.addLine(to: CGPoint(x: r.minX + w * 0.75, y: r.minY))
            p.addLine(to: CGPoint(x: r.maxX, y: r.midY))
            p.addLine(to: CGPoint(x: r.minX + w * 0.75, y: r.maxY))
            p.addLine(to: CGPoint(x: r.minX + w * 0.25, y: r.maxY))
            p.addLine(to: CGPoint(x: r.minX, y: r.midY))
            p.closeSubpath()
        }
    }
}
