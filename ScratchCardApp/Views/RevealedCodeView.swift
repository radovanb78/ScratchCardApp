import SwiftUI

struct RevealedCodeView: View {
    private let code: String

    init(code: String?) {
        self.code = code ?? ""
    }
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.blue)
            .frame(width: 300, height: 300)
            .overlay {
                Text(code)
                    .foregroundColor(.white)
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .multilineTextAlignment(.center)
                    .padding()
            }
    }
}

#Preview {
    RevealedCodeView(code: "12345")
}
