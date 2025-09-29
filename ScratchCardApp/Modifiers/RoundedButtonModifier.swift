import SwiftUI

struct RoundedButtonModifier: ViewModifier {
    var color: Color

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .padding()
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}

extension View {
    func roundedButton(color: Color) -> some View {
        self.modifier(RoundedButtonModifier(color: color))
    }
}
