import Foundation

protocol AnyDecoder {
    
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T

}

extension JSONDecoder: AnyDecoder {}
extension PropertyListDecoder: AnyDecoder {}

extension Data {

    var sizeKB: Double {
        return Double(count) / 1024
    }
    
    func decode<T: Decodable>(using decoder: AnyDecoder = JSONDecoder()) throws -> T {
        return try decoder.decode(T.self, from: self)
    }

}
