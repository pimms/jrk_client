import Foundation

extension Data {
    func deserializeAsJson() -> Any? {
        return try? JSONSerialization.jsonObject(with: self, options: [])
    }
}
