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
    
    init(config: CloudConfig, data: [WeatherPoint]) {
        self.config = config
        self.data = data
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
    
    func fetched(_ locations: [Station]) {
        Log.debug("Fetched \(locations.count) locations")
        
        let unknown = data.filter({
            let column = $0
            if let _ = locations.index(where: { $0.name == column.name }) {
                return false
            }
            
            return true
        })
        
        Log.debug("Have \(unknown.count) unknown locations")
        
        let afterCreateClosure: () -> () = {
            
        }
        
        if unknown.count == 0 {
            afterCreateClosure()
        } else {
            let request = CreateStationsRequest(config: config, create: unknown)
            request.execute() {
                created in
            }
        }
    }
}
