import Foundation

enum NetworkUtils {
    static func encodeToQueryItems<T: Encodable>(_ value: T, encoder: JSONEncoder = JSONEncoder()) -> [URLQueryItem]? {
        guard let data = try? encoder.encode(value),
              let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }

        return dict.map { key, value in
            URLQueryItem(name: key, value: "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))
        }
    }
}
