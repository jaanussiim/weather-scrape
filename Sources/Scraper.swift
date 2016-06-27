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

class Scraper {
    private let config: CloudConfig
    
    init(config: CloudConfig) {
        self.config = config
    }
    
    func scrape() {
        Log.debug("Scrape")
        
        let ilm = Ilmateenistus()
        ilm.fetch() {
            table in
            
            let places = Places.load()
            let data = table.tableByAppending(other: places)
            Log.debug(data)

            let points = WeatherPoint.from(table: data)
            
            let cloud = TheCloud(config: self.config, data: points)
            cloud.upload()
        }
    }
}
