//
//  FeelTableParseTests.swift
//  WeatherScrape
//
//  Created by Jaanus Siim on 25/06/16.
//  Copyright © 2016 Coodly LLC. All rights reserved.
//

import XCTest
@testable import WeatherScrape

class FeelTableParseTests: XCTestCase, DataLoader {
    func testTableParse() {
        let data = dataFromFile(named: "Tuulekulm")
        
        let table = Page.parseTable(from: data)
        XCTAssertNotNil(table)
        guard let t = table else {
            return
        }
        
        XCTAssertEqual(29, t.rows.count)
        
        guard let first = t.rows.first else {
            return
        }
        
        XCTAssertEqual(5, first.columns.count)
    }
}
