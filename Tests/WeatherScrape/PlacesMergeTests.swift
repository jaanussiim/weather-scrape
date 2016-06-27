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

class PlacesMergeTests: XCTestCase, DataLoader {
    private var hourlyTabel: Table!
    private var placesTable: Table!
    
    override func setUp() {
        super.setUp()
        
        let data = dataFromFile(named: "Tunniandmed")
        hourlyTabel = Page.parseTable(from: data)

        placesTable = Places.load()
    }
    
    func testAllPlacesHaveCoordinate() {
        let merged = hourlyTabel.tableByAppending(other: placesTable)
        for row in merged.rows {
            let station = row.column(named: "Station")
            let lat = row.column(named: "Lat")
            let lng = row.column(named: "Lng")
            
            XCTAssertNotNil(lat, "\(station!.value) missing lat")
            XCTAssertNotNil(lng, "\(station!.value) missing lng")
        }
    }
}
