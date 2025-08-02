import XCTest
@testable import ScratchCardApp

final class OtherTests: XCTestCase {
    func testQuertEncoder() {
        struct TestStruct: Encodable {
            let atribute1: String
            let atribute2: Int
            let atribute3: Bool
            let atribute4: Double
        }

        let queryItems1 = NetworkUtils.encodeToQueryItems(ActivationRequest(code: "Ahoj, ako sa máš?"))
        let queryItems2 = NetworkUtils.encodeToQueryItems(TestStruct(atribute1: "12345-67890", atribute2: 1, atribute3: true, atribute4: 1.2))

        XCTAssertEqual(queryItems1?.count, 1)
        XCTAssertEqual(queryItems1?[0], URLQueryItem(name: "code", value: "Ahoj,%20ako%20sa%20m%C3%A1%C5%A1?"))
        XCTAssertEqual(queryItems2?.count, 4)
    }

    func testActivationResponse() {
        let activationResponse1 = ActivationResponse(ios: "6.1")
        let activationResponse2 = ActivationResponse(ios: "6.100")
        let activationResponse3 = ActivationResponse(ios: "6.100.0")

        XCTAssertTrue(activationResponse1.isGreatetVersionNumber(then: "6.0"))
        XCTAssertFalse(activationResponse1.isGreatetVersionNumber(then: "6.1"))
        XCTAssertFalse(activationResponse1.isGreatetVersionNumber(then: "6.23"))
        XCTAssertTrue(activationResponse2.isGreatetVersionNumber(then: "6.10"))
        XCTAssertFalse(activationResponse2.isGreatetVersionNumber(then: "6.100.0"))
        XCTAssertFalse(activationResponse3.isGreatetVersionNumber(then: "6.100"))
    }
}
