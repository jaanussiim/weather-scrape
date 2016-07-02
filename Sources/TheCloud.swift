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

class TheCloud {
    private let config: CloudConfig
    private let data: [WeatherPoint]
    private let measuredAt: Date
    
    init(config: CloudConfig, measuredAt: Date, data: [WeatherPoint]) {
        self.config = config
        self.data = data
        self.measuredAt = measuredAt
    }
    
    func upload() {
        Log.debug("Upload")
        listLocations()
    }
    
    func listLocations() {
        Log.debug("List locationss")
        let request = ListStationsRequest(config: config)
        request.execute() {
            locations in
            
            self.fetched(locations)
        }
    }
    
    func fetched(_ stations: [Station]) {
        Log.debug("Fetched \(stations.count) station")
        
        let unknown = data.filter({
            let column = $0
            if let _ = stations.index(where: { $0.name == column.name }) {
                return false
            }
            
            return true
        })
        
        Log.debug("Have \(unknown.count) unknown locations")
        
        let afterCreateClosure: ([Station]) -> () = {
            stations in
            
            self.createRecord(points: self.data, stations: stations)
        }
        
        if unknown.count == 0 {
            afterCreateClosure(stations)
        } else {
            let request = CreateStationsRequest(config: config, create: unknown)
            request.execute() {
                created in
                
                let totalStations = stations + created
                afterCreateClosure(totalStations)
            }
        }
    }
    
    func createRecord(points: [WeatherPoint], stations: [Station]) {
        Log.debug("Create record for \(points.count) points from \(stations.count) stations")
        
        let request = CreateRecordRequest(config: config, measuredAt: measuredAt)
        request.execute() {
            record in
            
            self.createMeasurements(record: record.first!, points: points, stations: stations)
        }
    }
    
    func createMeasurements(record: Record, points: [WeatherPoint], stations: [Station]) {
        Log.debug("Create measurements")
        let request = CreateMeasurementsRequest(config: config, record: record, points: points, stations: stations)
        request.execute() {
            measurements in
            
            Log.debug("\(measurements.count) measuremenets created")
            self.updateTrigger(with: record)
        }
    }
    
    func updateTrigger(with record: Record) {
        Log.debug("Create trigger for \(record)")
        let request = FetchTriggerRequest(config: config)
        request.execute() {
            triggers in
            
            Log.debug("Fetched \(triggers.count) triggers")
            let request = PullTriggerRequest(config: self.config, trigger: triggers.first, record: record)
            request.execute() {
                trigger in
                
                Log.debug("Trigger pulled")
            }
        }
    }
}
