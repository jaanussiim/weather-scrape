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

struct Time {
    let year: Int
    let month: Int
    let day: Int
    let hour: Int
    let minute: Int
}

extension Date {
    func isSame(_ time: Time) -> Bool {
        let units: Calendar.Unit = [.year, .month, .day, .hour, .minute]
        let components = Calendar.current().components(units, from: self)
        return components.year == time.year
            && components.month == time.month
            && components.day == time.day
            && components.hour == time.hour
            && components.minute == time.minute
    }
}
