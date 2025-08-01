import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ViewModel(service: NetworkService(), exclusiveMin: "6.1")

    var body: some View {
        NavigationView {
            VStack {
                Spacer()

                VStack(spacing: 20) {
                    Text("Scratch Card Status")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    StateDisplayView(state: viewModel.state)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                Spacer()
                
                VStack(spacing: 16) {
                    NavigationLink(destination: ScratchView(viewModel: viewModel)) {
                        HStack {
                            Image(systemName: "hand.tap")
                            Text("Scratch Card")
                        }
                        .roundedButton(color: .blue)
                    }

                    NavigationLink(destination: ActivationView(viewModel: viewModel)) {
                        HStack {
                            Image(systemName: "checkmark.circle")
                            Text("Activate Card")
                        }
                        .roundedButton(color: viewModel.state.step < ScratchCardState.scratched().step ? .gray : .green)
                    }
                    .disabled(viewModel.state.step < ScratchCardState.scratched().step)
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
} 
