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

class CloudConfig {
    let environment: String
    let container: String
    let keyID: String
    
    init(path: String) {
        let data = try! Data(contentsOf: URL(fileURLWithPath: pathToConfig))
        let content = try! JSONSerialization.jsonObject(with: data) as! [String: String]
        environment = content["environment"]!
        container = content["container"]!
        keyID = content["keyID"]!
    }
}
