enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
}

protocol NetworkServiceProtocol: Sendable {
    func networkRequest<RequestData: Encodable, ResponseData: Decodable>(
        url: String,
        method: HttpMethod,
        requestData: RequestData?
    ) async throws -> ResponseData
}
