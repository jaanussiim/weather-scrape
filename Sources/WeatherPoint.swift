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

struct WeatherPoint {
    let name: String
    let lat: Double
    let lng: Double
    let temperature: Double?
    let conditions: String?
    let precipitation: Double?
    let windChill: Double?
    let windDirection: Int?
    let windStrength: Double?
    
    static func from(table: Table) -> [WeatherPoint] {
        var result = [WeatherPoint]()
        
        for row in table.rows {
            guard let name = row.column(named: "Station")?.value else {
                continue
            }
            
            
            //TODO jaanus: check issue where Tuulemäe coordinates not merged
            guard let lat = row.double("Lat") else {
                continue
            }
            guard let lng = row.double("Lng") else {
                continue
            }
            
            let temperature = row.double("Air temperature (°C)")
            let conditions = row.column(named: "Present weather (sensor)")?.value
            let precipitation = row.double("Precipitation (mm)")
            let windChill = row.double("Wind chill (°C)")
            let windDirection = row.integer("Wind - direction (°)")
            let windStrength = row.double("Wind - speed (m/s)")
            
            let point = WeatherPoint(name: name, lat: lat, lng: lng, temperature: temperature, conditions: conditions, precipitation: precipitation, windChill: windChill, windDirection: windDirection, windStrength: windStrength)
            result.append(point)
        }
        
        return result
    }
}
