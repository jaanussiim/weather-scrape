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

struct Table: CustomStringConvertible {
    let rows: [Row]
    let measuredAt: Date?
    
    func tableByAppending(other: Table) -> Table {
        var resultRows = [Row]()
        for row in rows {
            var modified = row
            if let stationColumn = row.column(named: "Station"), otherRow = other.row(withColumn: stationColumn) {
                var added = otherRow.columns
                if let index = added.index(where: {$0.title == stationColumn.title}) {
                    added.remove(at: index)
                }
                
                modified.append(columns: added)
            }
            
            resultRows.append(modified)
        }
        
        return Table(rows: resultRows, measuredAt: measuredAt)
    }
    
    func row(withColumn: Column) -> Row? {
        for row in rows {
            guard let column = row.column(named: withColumn.title) else {
                continue
            }
            
            if column.value == withColumn.value {
                return row
            }
        }
        
        return nil
    }
    
    var description: String {
        let included = ["Station", "Air temperature (°C)", "Wind chill (°C)", "Wind - direction (°)", "Present weather (sensor)", "Precipitation (mm)", "Wind - speed (m/s)", "Lat", "Lng"]
        
        var result = included.joined(separator: "\t|")
        
        for row in rows {
            var rowData = "\n"
            var components = [String]()
            for c in included {
                if let column = row.column(named: c) {
                    components.append(column.value)
                } else {
                    components.append("")
                }
            }
            rowData += components.joined(separator: "\t|")
            result.append(rowData)
        }
        
        return result
    }
}
