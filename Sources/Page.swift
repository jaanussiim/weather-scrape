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

private struct ColumnDef {
    let name: String
    let span: Int
}

class Page {
    let path: String
    var hadError = false
    var table: Table?
    
    init(path: String) {
        self.path = path
    }
    
    func fetch() {
        Log.debug("fetch \(path)")
        let request = PageRequest(page: path)
        request.resultHandler = {
            data, error in
            
            if let _ = error {
                self.hadError = true
            } else if let pageData = data {
                self.table = Page.parseTable(from: pageData)
            }
        }
        request.execute()
    }
    
    class func parseTable(from data: Data) -> Table? {
        guard let doc = HTML(html: data, encoding: String.Encoding.utf8) else {
            return nil
        }
        
        guard let tableContainer = doc.xpath("//*[contains(concat(' ', @class, ' '), ' viewControllerContent')][2]").first else {
            return nil
        }
        
        let table = tableContainer.xpath("//table").first!

        let headerRows = table.xpath("//thead/tr[1]").first!
        var definitions = [ColumnDef]()
        var totalSpan = 0
        for column in headerRows.xpath("//th") {
            let name = column.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let span: Int
            if let spanValue = column["colspan"], value = Int(spanValue) {
                span = value
            } else {
                span = 1
            }
            
            
            if span > 1 {
                totalSpan += span
            }
            
            definitions.append(ColumnDef(name: name, span: span))
        }
        
        Log.debug("Definitions:\n\(definitions.map({ $0.name }).joined(separator: "\n"))")
        
        let main = definitions.prefix(definitions.count - totalSpan)
        var sub = Array(definitions.suffix(totalSpan))
        var subIndex = 0
        var columns = [String]()
        for def in main {
            let span = def.span
            if span == 1 {
                columns.append(def.name)
            } else {
                var count = span
                while count > 0 {
                    let s = sub[subIndex]
                    columns.append("\(def.name) - \(s.name)")
                    
                    count -= 1
                    subIndex += 1
                }
            }
        }
        
        Log.debug("Column names: \(columns)")
        let body = table.xpath("//tbody").first!
        
        var rows = [Row]()
        
        var rowColumns = [Column]()
        for cell in body.xpath("//tr/td") {
            let title = columns[rowColumns.count]
            let value = cell.text!
            
            rowColumns.append(Column(title: title, value: value))
            
            if rowColumns.count == columns.count {
                rows.append(Row(columns: rowColumns))
                rowColumns.removeAll(keepingCapacity: true)
            }
        }
        
        return Table(rows: rows)
    }
}
