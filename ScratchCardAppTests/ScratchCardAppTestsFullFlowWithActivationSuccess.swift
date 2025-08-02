import XCTest
@testable import ScratchCardApp

final class ScratchCardAppTestsFullFlowWithActivationSuccess: XCTestCase {
    var viewModel: ScratchCardViewModel!

    override func setUp() async throws {
        try await super.setUp()
        let service: NetworkServiceProtocol = MockNetworkService(
            responseData: ActivationResponse(ios: "6.1")
        )

        viewModel = await MainActor.run {
            ScratchCardViewModel(
                service: service,
                exclusiveMin: "6.1"
            )
        }
    }

    override func tearDown() async throws{
        await MainActor.run {
            viewModel.cancelCodeGeneration()
        }
        viewModel = nil
        try await super.tearDown()
    }

    func test() async {
        // test generate code
        let code = try? await viewModel.generateCode()
        XCTAssertNotNil(code)
        await MainActor.run {
            XCTAssertTrue(viewModel.state.step == ScratchCardState.generated().step)
            XCTAssertNotNil(viewModel.code)
        }

        // test scratch
        await MainActor.run {
            viewModel.setScratched()
            XCTAssertTrue(viewModel.isScratched)
            XCTAssertNotNil(viewModel.revealedCode)
        }

        // test activate
        let result = await viewModel.activate()
        await MainActor.run {
            XCTAssertFalse(result)
            XCTAssertTrue(viewModel.isScratched)
            XCTAssertFalse(viewModel.state.step == ScratchCardState.activated().step)
            XCTAssertNotNil(viewModel.revealedCode)
        }
    }
}
