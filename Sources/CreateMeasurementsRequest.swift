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

class CreateMeasurementsRequest: CloudRequest<Measurement> {
    private let record: Record
    private let points: [WeatherPoint]
    private let stations: [Station]
    
    init(config: CloudConfig, record: Record, points: [WeatherPoint], stations: [Station]) {
        self.record = record
        self.points = points
        self.stations = stations
        
        super.init(config: config)
    }
    
    override func performRequest() {
        var body = [String: AnyObject]()
        var operations = [[String: AnyObject]]()
        for point in points {
            guard let station = stationFor(point: point) else {
                Log.debug("No station for \(point)")
                continue
            }
            
            var fields = [String: AnyObject]()
            if let conditions = point.conditions {
                fields["conditions"] = ["value": conditions]
            }
            fields["precipitation"] = ["value": point.precipitation]
            fields["record"] = ["value": ["recordName": self.record.recordName!, "action": "DELETE_SELF"]]
            fields["schemaVersion"] = ["value": "v1"]
            fields["station"] = ["value": ["recordName": station.recordName!, "action": "DELETE_SELF"]]
            fields["temperature"] = ["value": point.temperature]
            fields["windChill"] = ["value": point.windChill]
            fields["windDirection"] = ["value": point.windDirection]
            fields["windStrength"] = ["value": point.windStrength]
            
            let record: [String: AnyObject] = ["recordType": "Measurement", "fields": fields]
            let op: [String: AnyObject] = ["operationType": "create", "record": record]
            operations.append(op)
        }
        body["operations"] = operations
        
        cloudRequest(to: "records/modify", body: body)
    }
    
    func stationFor(point: WeatherPoint) -> Station? {
        return stations.first(where: { $0.name == point.name })
    }
 }
