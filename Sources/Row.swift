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

struct Row {
    private(set) var columns: [Column]
    
    func column(named: String) -> Column? {
        return columns.filter({ $0.title == named}).first
    }
    
    mutating func append(columns: [Column]) {
        let nextColumns = self.columns + columns
        self.columns = nextColumns
    }
    
    func double(_ name: String) -> Double? {
        guard let c = string(for: name) else {
            return nil
        }
        
        return Double(c)
    }

    func integer(_ name: String) -> Int? {
        guard let c = string(for: name) else {
            return nil
        }
        
        return Int(c)
    }
    
    private func string(for name: String) -> String? {
        guard let s = column(named: name)?.value else {
            return nil
        }
        
        let stripped = s.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines())
        let cleaned = stripped.replacingOccurrences(of: ",", with: ".")
        return cleaned
    }
}
