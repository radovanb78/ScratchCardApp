import SwiftUI

struct ScratchView: View {
    @ObservedObject var viewModel: ViewModel

    @State private var points: [CGPoint] = []

    private let gridSize = 5
    private let gridCellSize = 50
    private let scratchClearAmount: CGFloat = 0.6

    var body: some View {
        VStack {
            Spacer()

            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray)
                    .frame(width: 300, height: 300)
                    .overlay {
                        if viewModel.canScratch {
                            Image(systemName: "hand.tap.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.blue)
                        } else {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(2)
                                .tint(.blue)
                        }
                    }

                if viewModel.canScratch {
                    RevealedCodeView(code: viewModel.code)
                    // inspired by https://github.com/anupdsouza/ios-scratch-card-view
                        .mask(
                            Path { path in
                                path.addLines(points)
                            }.stroke(style: StrokeStyle(lineWidth: 50, lineCap: .round, lineJoin: .round))
                        )
                        .gesture(
                            DragGesture(minimumDistance: 0, coordinateSpace: .local)
                                .onChanged { value in
                                    points.append(value.location)
                                }
                                .onEnded { _ in
                                    let cgpath = Path { path in
                                        path.addLines(points)
                                    }.cgPath

                                    let thickenedPath = cgpath.copy(
                                        strokingWithWidth: 50,
                                        lineCap: .round,
                                        lineJoin: .round,
                                        miterLimit: 10
                                    )

                                    var scratchedCount = 0

                                    for i in 0..<gridSize {
                                        for j in 0..<gridSize {
                                            let point = CGPoint(x: gridCellSize / 2 + i * gridCellSize, y: gridCellSize / 2 + j * gridCellSize)
                                            if thickenedPath.contains(point) {
                                                scratchedCount += 1
                                            }
                                        }
                                    }

                                    let scratchedPercentage = Double(scratchedCount) / Double(gridSize * gridSize)

                                    if scratchedPercentage > scratchClearAmount {
                                        viewModel.setScratched()
                                    }
                                }
                        )
                } else if viewModel.state.step >= ScratchCardState.scratched().step {
                    RevealedCodeView(code: viewModel.code)
                }
            }

            Spacer()

            Button(action: {
                viewModel.setScratched()
            }) {
                HStack {
                    Image(systemName: "hand.tap")
                    Text("Scratch Card")
                }
                .roundedButton(color: !viewModel.canScratch ? Color.gray : Color.blue)
            }
            .disabled(!viewModel.canScratch)

            Spacer()
        }
        .padding()
        .navigationTitle("Scratch")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                await viewModel.generateCode()
            }
        }
        .onDisappear {
            viewModel.cancelCodeGeneration()
        }
    }
}

#Preview {
    NavigationView {
        ScratchView(viewModel: ViewModel(service: NetworkService(), exclusiveMin: "6.1"))
    }
}
