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

class PullTriggerRequest: CloudRequest<Trigger> {
    private let existing: Trigger?
    private let record: Record
    
    init(config: CloudConfig, trigger: Trigger?, record: Record) {
        existing = trigger
        self.record = record
        super.init(config: config)
    }
    
    override func performRequest() {
        var body = [String: AnyObject]()
        var fields = [String: AnyObject]()
        fields["key"] = ["value": self.record.recordName!]
        fields["schemaVersion"] = ["value": "v1"]
        var record: [String: AnyObject] = ["recordType": "Trigger", "fields": fields]
        let operation: String
        if let trigger = existing {
            record["recordName"] = trigger.recordName!
            operation = "forceUpdate"
        } else {
            operation = "create"
        }
        let op: [String: AnyObject] = ["operationType": operation, "record": record]
        body["operations"] = [op]
        cloudRequest(to: "records/modify", body: body)
}
}
