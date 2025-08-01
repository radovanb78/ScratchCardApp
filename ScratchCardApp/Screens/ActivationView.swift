import SwiftUI

struct ActivationView: View {
    @ObservedObject var viewModel: ViewModel
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 20) {
                if viewModel.isActivated {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                }

                Text("Activate Card")
                    .font(.title)
                    .fontWeight(.bold)
                
                if let code = viewModel.revealedCode {
                    Text("Code: \(code)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding()
                        .backgroundStyle(Color(.systemGray6))
                        .cornerRadius(8)
                }
                
                Text("Tap the button below to activate your card")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            Button(action: {
                Task {
                    await activateCard()
                }
            }) {
                HStack {
                    if viewModel.isActivating {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "checkmark.circle")
                    }
                    Text(viewModel.isActivating ? "Activating..." : "Activate Card")
                }
                .roundedButton(color: viewModel.isActivating || viewModel.isActivated ? .gray : .green)
            }
            .disabled(viewModel.isActivating || viewModel.isActivated)

            Spacer()
        }
        .padding()
        .navigationTitle("Activate")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Activation Error", isPresented: $showAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func activateCard() async {
        guard viewModel.isScratched else { return }
        
        let success = await viewModel.activate()

        await MainActor.run {
            if !success {
                alertMessage = "Activation failed. Please try again later."
                showAlert = true
            }
        }
    }
}

#Preview {
    NavigationView {
        ActivationView(viewModel: ViewModel(service: NetworkService(), exclusiveMin: "6.1"))
    }
} 
