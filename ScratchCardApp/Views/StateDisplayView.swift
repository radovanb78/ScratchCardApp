import SwiftUI

struct StateDisplayView: View {
    let state: ScratchCardState
    
    var body: some View {
        VStack(spacing: 16) {
            switch state {
                case .initial, .generated:
                Image(systemName: "rectangle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.gray)
                Text("Unscratched")
                    .font(.headline)
                    .foregroundColor(.gray)
                
            case .scratched(let code):
                Image(systemName: "rectangle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.orange)
                Text("Scratched")
                    .font(.headline)
                    .foregroundColor(.orange)
                Text("Code: \(code)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
            case .activated(let code):
                Image(systemName: "checkmark.rectangle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.green)
                Text("Activated")
                    .font(.headline)
                    .foregroundColor(.green)
                Text("Code: \(code)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    StateDisplayView(state: .activated(code: "12345"))
}
