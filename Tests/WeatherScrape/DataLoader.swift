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

protocol DataLoader {
    func dataFromFile(named: String, type: String) -> Data
}

extension DataLoader {
    func dataFromFile(named: String, type: String = "html") -> Data {
        let testFilePath = "TestData/\(named).\(type)"
        let url = URL(fileURLWithPath: testFilePath)
        return try! Data(contentsOf: url)
    }
}
