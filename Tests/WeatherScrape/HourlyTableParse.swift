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

import XCTest
@testable import WeatherScrape

class HourlyTableParse: XCTestCase, DataLoader {
    func testHourlyTableParse() {
        let data = dataFromFile(named: "Tunniandmed")
        
        let table = Page.parseTable(from: data)
        XCTAssertNotNil(table)
        
        guard let t = table else {
            return
        }
        
        XCTAssertNotNil(t.measuredAt)
        if let m = t.measuredAt {
            XCTAssertTrue(m.isSame(Time(year: 2016, month: 06, day: 25, hour: 14, minute: 0)), "Got \(m)")
        }

        XCTAssertEqual(85, t.rows.count)
        
        guard let first = t.rows.first else {
            return
        }
        
        XCTAssertEqual(13, first.columns.count)
    }
}
