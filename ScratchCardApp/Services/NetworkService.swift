import Foundation

enum NetworkError: Error {
    case invalidURL
    case decodingError
    case serverError(String)
}

enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
}

protocol NetworkServiceProtocol {
    func networkRequest<RequestData: Encodable, ResponseData: Decodable>(
        url: String,
        method: HttpMethod,
        requestData: RequestData?
    ) async throws -> ResponseData
}

final class NetworkService: NetworkServiceProtocol {
    private func encodeToQueryItems<RequestData: Encodable>(_ value: RequestData) -> [URLQueryItem]? {
        guard let data = try? JSONEncoder().encode(value),
              let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        
        return dict.map { key, value in
            URLQueryItem(name: key, value: "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))
        }
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
                    urlComponents.queryItems = encodeToQueryItems(requestData)
                case .post:
                    bodyData = try JSONEncoder().encode(requestData)
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
