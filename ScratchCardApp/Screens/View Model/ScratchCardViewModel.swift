import Foundation

enum ScratchCardState: Equatable {
    case initial
    case generated(code: String = "")
    case scratched(code: String = "")
    case activated(code: String = "")

    var step: Int {
        switch self {
            case .initial:
                return 0
            case .generated:
                return 1
            case .scratched:
                return 2
            case .activated:
                return 3
        }
    }
}

@MainActor
final class ScratchCardViewModel: ObservableObject {
    @Published private(set) var state: ScratchCardState = .initial
    @Published private(set) var isActivating: Bool = false

    nonisolated private let service: NetworkServiceProtocol
    private let exclusiveMin: String

    init(service: NetworkServiceProtocol, exclusiveMin: String) {
        self.service = service
        self.exclusiveMin = exclusiveMin
    }

    private var codeGenerationTask: Task<String, Error>?

    func setScratched() {
        guard case .generated(let code) = state else { return }
        state = .scratched(code: code)
    }

    var canScratch: Bool {
        if case .generated = state {
            return true
        }
        return false
    }

    var isScratched: Bool {
        if case .scratched = state {
            return true
        }
        return false
    }

    var isActivated: Bool {
        if case .activated = state {
            return true
        }
        return false
    }

    var code: String? {
        switch state {
            case .generated(code: let code):
                code
            default:
                revealedCode
        }
    }

    var revealedCode: String? {
        switch state {
        case .scratched(let code), .activated(let code):
            code
        default:
            nil
        }
    }

    func generateCode(
        wait: @escaping () async throws -> Void = {
            try await Task.sleep(for: .seconds(2))
        }
    ) async throws -> String {
        guard case .initial = state,
              codeGenerationTask == nil else { throw NSError(domain: "CodeGenerationError", code: 100, userInfo: nil) }

        codeGenerationTask = Task<String, Error> { [weak self] in
            do {
                try await wait()
                try Task.checkCancellation()
                let code = UUID().uuidString
                return await MainActor.run {
                    self?.state = .generated(code: code)
                    return code
                }
            } catch {
                print("Code generation operation was cancelled or failed: \(error)")
                throw error
            }
        }

        return try await codeGenerationTask!.value
    }

    func cancelCodeGeneration() {
        codeGenerationTask?.cancel()
        codeGenerationTask = nil
    }

    func activate() async -> Bool {
        guard case .scratched(let code) = state else { return false }
        isActivating = true
        do {
            let response: ActivationResponse = try await service.networkRequest(
                url: "https://api.o2.sk/version",
                method: .get,
                requestData: ActivationRequest(code: code)
            )

            let result = response.isGreaterVersionNumber(then: exclusiveMin)

            await MainActor.run {
                if result {
                    self.state = .activated(code: code)
                }
                self.isActivating = false
            }
            
            return result
        } catch {
            return false
        }
    }
}
