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

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
}

enum Result: CustomStringConvertible {
    case Success(Int, Data)
    case Error(NSError)
    case Unknown
    
    var description: String {
        switch self {
        case .Unknown:
            return "Unknown"
        case .Error(let error):
            return "Error \(error)"
        case .Success(let status, let data):
            return "Success - status: \(status). data: \(data.count)"
        }
    }
}

class NetworkRequest {
    private let baseURL: URL
    var logContent = false
    
    init(baseURL: URL) {
        self.baseURL = baseURL
    }
    
    final func GET(_ path: String, params: [String: AnyObject] = [:]) {
        executeRequest(method: .GET, path: path, params: params)
    }
    
    final func POST(to path: String, body: Data? = nil) {
        executeRequest(method: .POST, path: path, params: [:], body: body)
    }
    
    private func executeRequest(method: HTTPMethod, path: String, params: [String: AnyObject], body: Data? = nil) {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
        components.path = components.path?.appending(path)
        
        var queryItems = [URLQueryItem]()
        for (name, value) in params {
            queryItems.append(URLQueryItem(name: name, value: "\(value)"))
        }
        if queryItems.count > 0 {
            components.queryItems = queryItems
        }
        
        let requestURL = components.url!
        Log.debug("\(method) to \(requestURL)")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = method.rawValue
        request.addValue("www.jaanussiim.com / jaanussiim@gmail.com", forHTTPHeaderField: "User-Agent")

        let additionalHeaders = customHeaders()
        for (name, value) in additionalHeaders {
            request.addValue(value, forHTTPHeaderField: name)
        }
        
        if let bodyData = body {
            Log.debug("Attach body \(bodyData.count)")
            request.httpBody = bodyData
        }
        
        Log.debug("Headers: \(request.allHTTPHeaderFields)")
        
        let completion: (Data?, URLResponse?, NSError?) -> () = {
            data, response, error in
            
            var statusCode = 0
            if self.logContent, let httpResponse = response as? HTTPURLResponse {
                Log.debug("Response code \(httpResponse.statusCode)")
                Log.debug("Headers: \(httpResponse.allHeaderFields)")
                statusCode = httpResponse.statusCode
            }
            if self.logContent, let data = data, string = String(data: data, encoding: String.Encoding.utf8) {
                Log.debug("Response body\n\n \(string)")
            }
            
            if let error = error {
                self.handle(result: .Error(error))
            } else if let data = data {
                self.handle(result: .Success(statusCode, data))
            } else {
                self.handle(result: .Unknown)
            }
        }
        
        URLSession.shared().synchronousDataWithRequest(request: request, completionHandler: completion)
    }
    
    func execute() {
        fatalError("Overrie: \(#function)")
    }
    
    func handle(result: Result) {
        Log.debug("Handle: \(result)")
    }
    
    func customHeaders() -> [String: String] {
        return [:];
    }
}

extension URLSession {
    func synchronousDataWithRequest(request: URLRequest, completionHandler: (Data?, URLResponse?, NSError?) -> Void) {
        var data: Data?
        var response: URLResponse?
        var error: NSError?
        
        let sem = DispatchSemaphore(value: 0)
        let task = dataTask(with: request, completionHandler: {
            data = $0
            response = $1
            error = $2
            sem.signal()
        })
        
        task.resume()
        
        sem.wait(timeout: DispatchTime.distantFuture)
        completionHandler(data, response, error)
    }
}
