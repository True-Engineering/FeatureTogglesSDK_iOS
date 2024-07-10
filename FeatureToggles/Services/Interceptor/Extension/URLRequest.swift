import Foundation

private enum Constants {
    static let bufferMaxLength = 4096
}

extension URLRequest {
    
    func getHttpBodyStreamData() -> Data? {
        guard let httpBodyStream = self.httpBodyStream else {
            return nil
        }
        
        let data = NSMutableData()
        var buffer = [UInt8](repeating: 0, count: Constants.bufferMaxLength)
        
        httpBodyStream.open()
        
        while httpBodyStream.hasBytesAvailable {
            let length = httpBodyStream.read(&buffer, maxLength: Constants.bufferMaxLength)
            if length == 0 {
                break
            } else {
                data.append(&buffer, length: length)
            }
        }
        
        httpBodyStream.close()
        
        return data as Data
    }
    
    mutating func modifyURLRequestEndpoint(redirectUrl: RedirectedRequestModel) {
        var urlString = url?.absoluteString ?? ""
        urlString = urlString.replacingOccurrences(of: redirectUrl.originalUrl, with: redirectUrl.redirectUrl)
        url = URL(string: urlString)
    }
    
    mutating func modifyURLRequestHeader(header: HeaderModifyModel) {
        setValue(header.value, forHTTPHeaderField: header.key)
    }
    
}
