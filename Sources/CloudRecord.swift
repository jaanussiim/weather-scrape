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

protocol CloudRecord {
    var recordName: String? { get set }
    
    init()
    
    mutating func load(from data: [String: AnyObject]) -> Bool
    mutating func loadFields(from data: [String: AnyObject]) -> Bool
}

extension CloudRecord {
    mutating func load(from data: [String: AnyObject]) -> Bool {
        guard let rName = data["recordName"] as? String else {
            return false
        }
    
        guard let fields = data["fields"] as? [String: AnyObject] else {
            return false
        }
        
        recordName = rName
        
        return loadFields(from: fields)
    }
}
