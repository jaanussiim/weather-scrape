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

class CreateStationsRequest: CloudRequest<Station> {
    private let create: [WeatherPoint]
    
    init(config: CloudConfig, create: [WeatherPoint]) {
        self.create = create
        super.init(config: config)
    }
    
    override func performRequest() {
        var body = [String: AnyObject]()
        var operations = [[String: AnyObject]]()
        for l in create {
            var fields = [String: AnyObject]()
            fields["name"] = ["value": l.name]
            fields["schemaVersion"] = ["value": "v1"]
            fields["coordinate"] = ["value": ["longitude": l.lng, "latitude": l.lat]]
            let record: [String: AnyObject] = ["recordType": "Station", "fields": fields]
            let op: [String: AnyObject] = ["operationType": "create", "record": record]
            operations.append(op)
        }
        body["operations"] = operations
        
        cloudRequest(to: "records/modify", body: body)
    }
}
