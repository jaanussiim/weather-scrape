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

let IlmateenusDataBase = "http://www.ilmateenistus.ee/ilm/ilmavaatlused/vaatlusandmed"
let HourlyDataPath = "/tunniandmed/"
let FeelTemperaturePath = "/tuulekulm/"

class Ilmateenistus {
    private var pages: [Page]!
    
    func fetch() {
        let pagesToLoad = [
            Page(path: HourlyDataPath),
            Page(path: FeelTemperaturePath)
        ]
        pages = pagesToLoad
        
        loadNext(pages: pagesToLoad)
    }
    
    private func loadNext(pages: [Page]) {
        guard let page = pages.first else {
            Log.debug("All pages loaded")
            handleData(in: self.pages)
            return
        }
        
        load(page) {
            let index = pages.index(where: {$0.path == page.path})!
            var remaining = pages
            remaining.remove(at: index)
            self.loadNext(pages: remaining)
        }
    }
    
    private func load(_ page: Page, completion: () -> ()) {
        Log.debug("Load \(page.path)")
        page.fetch()
        completion()
    }
    
    func handleData(in pages: [Page]) {
        if pages.filter({ $0.hadError }).count > 0 {
            Log.error("Had errors!")
            return
        }
        
        var worked = pages
        var table = worked.removeFirst().table!
        for page in worked {
            let otherTable = page.table!
            table = table.tableByAppending(other: otherTable)
        }
        
        Log.debug("Combined data:\n\(table)")
    }
}
