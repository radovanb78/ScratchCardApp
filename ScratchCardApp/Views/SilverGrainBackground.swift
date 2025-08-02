import SwiftUI

struct SilverGrainBackground: View {
    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                for x in 0..<Int(size.width) {
                    for y in 0..<Int(size.height) {
                        let grainColor = Color.gray.opacity(Double.random(in: 0.75...1))
                        let circle = Path(ellipseIn: CGRect(x: CGFloat(x), y: CGFloat(y), width: 1, height: 1))
                        context.fill(circle, with: .color(grainColor))
                    }
                }
            }
        }
    }
}
