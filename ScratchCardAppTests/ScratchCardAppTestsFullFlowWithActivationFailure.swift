import XCTest
@testable import ScratchCardApp

final class ScratchCardAppTests: XCTestCase {
    var viewModel: ScratchCardViewModel!

    override func setUp() async throws {
        try await super.setUp()
        let service: NetworkServiceProtocol = MockNetworkService(
            responseData: ActivationResponse(ios: "6.42.1")
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
        // test initial state
        await MainActor.run {
            XCTAssertTrue(viewModel.state == .initial)
            XCTAssertFalse(viewModel.isScratched)
            XCTAssertFalse(viewModel.isActivated)
            XCTAssertNil(viewModel.revealedCode)
        }

        // test scratch without generate first
        await MainActor.run {
            viewModel.setScratched()
            XCTAssertFalse(viewModel.isScratched)
            XCTAssertTrue(viewModel.state.step == ScratchCardState.initial.step)
        }

        // test generate code
        let code = try? await viewModel.generateCode(wait: {})
        XCTAssertNotNil(code)
        await MainActor.run {
            XCTAssertTrue(viewModel.state.step == ScratchCardState.generated().step)
            XCTAssertTrue(viewModel.canScratch)
            XCTAssertNotNil(viewModel.code)
            XCTAssertNil(viewModel.revealedCode)
        }

        // test activate without scratch first
        let result0 = await viewModel.activate()
        await MainActor.run {
            XCTAssertFalse(result0)
            XCTAssertFalse(viewModel.state.step == ScratchCardState.activated().step)
            XCTAssertTrue(viewModel.state.step == ScratchCardState.generated().step)
        }

        // test scratch
        await MainActor.run {
            viewModel.setScratched()
            XCTAssertTrue(viewModel.isScratched)
            XCTAssertFalse(viewModel.canScratch)
            XCTAssertNotNil(viewModel.code)
            XCTAssertNotNil(viewModel.revealedCode)
        }

        // test activate
        let result1 = await viewModel.activate()
        await MainActor.run {
            XCTAssertTrue(result1)
            XCTAssertTrue(viewModel.state.step == ScratchCardState.activated().step)
            XCTAssertNotNil(viewModel.revealedCode)
        }
    }
}
