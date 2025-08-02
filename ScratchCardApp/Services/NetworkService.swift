import Foundation

enum NetworkError: Error {
    case invalidURL
    case decodingError
    case serverError(String)
}

final class NetworkService: NetworkServiceProtocol {
    private let encoder: JSONEncoder

    init(encoder: JSONEncoder = JSONEncoder()) {
        self.encoder = encoder
    }

    func networkRequest<RequestData: Encodable, ResponseData: Decodable>(
        url: String,
        method: HttpMethod,
        requestData: RequestData?
    ) async throws -> ResponseData {
        guard var urlComponents = URLComponents(string: url) else {
            throw NetworkError.invalidURL
        }

        var bodyData: Data?

        if let requestData {
            switch method {
                case .get:
                    urlComponents.queryItems = NetworkUtils.encodeToQueryItems(requestData, encoder: encoder)
                case .post:
                    bodyData = try encoder.encode(requestData)
            }
        }

        guard let url = urlComponents.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = bodyData

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.serverError("Invalid response")
            }
            
            guard httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 else {
                throw NetworkError.serverError("HTTP \(httpResponse.statusCode)")
            }
            
            do {
                let response = try JSONDecoder().decode(ResponseData.self, from: data)
                return response
            } catch {
                throw NetworkError.decodingError
            }
        } catch {
            if error is NetworkError {
                throw error
            } else {
                throw NetworkError.serverError(error.localizedDescription)
            }
        }
    }
} 
