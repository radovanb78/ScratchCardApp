import Foundation

struct ActivationResponse: Decodable {
    let ios: String

    func isGreatetVersionNumber(then other: String) -> Bool {
        let lhsComponents = ios.split(separator: ".").map { Int($0) ?? 0 }
        let rhsComponents = other.split(separator: ".").map { Int($0) ?? 0 }

        let maxLength = max(lhsComponents.count, rhsComponents.count)
        let lhs = lhsComponents + Array(repeating: 0, count: maxLength - lhsComponents.count)
        let rhs = rhsComponents + Array(repeating: 0, count: maxLength - rhsComponents.count)

        for (l, r) in zip(lhs, rhs) {
            if l > r { return true }
        }

        return false
    }

    func isGreaterDecimalNumber(then other: String) throws -> Bool {
        guard let lhs = Decimal(string: ios),
              let rhs = Decimal(string: other) else {
            throw NSError(domain: "InvalidArgumentError", code: 100, userInfo: nil)
        }
        return lhs > rhs
    }
}
