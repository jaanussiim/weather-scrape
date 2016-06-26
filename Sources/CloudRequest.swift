/*
 * Copyright 2016 JaanusSiim
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation
import CommonCrypto

class CloudRequest: NetworkRequest {
    private let config: CloudConfig
    private lazy var dateString: String = {
        let formatter = DateFormatter()
        formatter.locale = Locale(localeIdentifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "GMT")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        return formatter.string(from: Date()).appending("Z")
    }()
    private var fullQueryPath: String!
    private var bodyData: Data!
    
    init(config: CloudConfig) {
        self.config = config
        
        super.init(baseURL: URL(string: "https://api.apple-cloudkit.com")!)
    }
    
    func cloudRequest(to path: String, query: [String: AnyObject]) {
        fullQueryPath = "/database/1/\(config.container)/\(config.environment)/public/\(path)"
        let body: [String: AnyObject] = ["query": query]
        bodyData = try! JSONSerialization.data(withJSONObject: body)
        POST(to: fullQueryPath, body: bodyData)
    }
    
    override func customHeaders() -> [String : String] {
        return [
            "X-Apple-CloudKit-Request-KeyID": config.keyID,
            "X-Apple-CloudKit-Request-ISO8601Date": dateString,
            "X-Apple-CloudKit-Request-SignatureV1": calculateSignature()
        ]
    }
    
    private func calculateSignature() -> String {
        let base = "\(dateString):\(bodyHash()):\(fullQueryPath!)"
        return base
    }
    
    private func bodyHash() -> String {
        Log.debug("Body: \(String(data: bodyData, encoding: String.Encoding.utf8))")
        let sha256Data = sha256(data: bodyData)
        let hex = NSData(data: sha256Data).toHexString()
        Log.debug("SHA256: \(hex)")
        let result = hex.data(using: String.Encoding.utf8)!.base64EncodedString()
        Log.debug("Result: \(result)")
        return result
        //let resultString = NSData(data: result).toHexString()
        //Log.debug("Result: \(resultString)")
        //return resultString
    }
    
    private func sha256(data : Data) -> Data {
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0, CC_LONG(data.count), &hash)
        }
        return Data(bytes: hash)
    }
}

extension NSData {
    func toHexString() -> String {
        
        var string = NSMutableString(capacity: length * 2)
        var byte: UInt8 = 0
        
        for i in 0 ..< length {
            getBytes(&byte, range: NSMakeRange(i, 1))
            string.appendFormat("%02x", byte)
        }
        
        return string as String
    }
}
