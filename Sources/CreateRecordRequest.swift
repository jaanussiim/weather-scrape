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

class CreateRecordRequest: CloudRequest<Record> {
    private let measuredAt: Date
    
    init(config: CloudConfig, measuredAt: Date) {
        self.measuredAt = measuredAt
        
        super.init(config: config)
    }
    
    override func performRequest() {
        var body = [String: AnyObject]()
        var fields = [String: AnyObject]()
        fields["measuredAt"] = ["value": measuredAt.milliseconds()]
        fields["schemaVersion"] = ["value": "v1"]
        let record: [String: AnyObject] = ["recordType": "Record", "fields": fields]
        let op: [String: AnyObject] = ["operationType": "create", "record": record]
        body["operations"] = [op]
        cloudRequest(to: "records/modify", body: body)
    }
}
