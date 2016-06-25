/*
* Copyright 2015 Coodly LLC
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

public class FileOutput: LogOutput {
    private var fileHandle: FileHandle!
    private let saveInDirectory: FileManager.SearchPathDirectory

    public init(saveInDirectory: FileManager.SearchPathDirectory = .documentDirectory) {
        self.saveInDirectory = saveInDirectory
    }
    
    public func log(_ message: String) {
        let written = "\(message)\n"
        let data = written.data(using: String.Encoding.utf8)!
        if let handle = handle() {
            handle.write(data)
        }
    }
    
    private func handle() -> FileHandle? {
        if let handle = fileHandle {
            return handle
        }

        let dir = FileManager.default().urlsForDirectory(saveInDirectory, inDomains: FileManager.SearchPathDomainMask.userDomainMask).last!
        let time = dateFormatter.string(from: Date())
        let logsFolder = try! dir.appendingPathComponent("Logs")
        let fileURL = try! logsFolder.appendingPathComponent("\(time).txt")
        createFolder(logsFolder)
        
        makeSureFileExists(fileURL)
        
        do {
            if let opened: FileHandle = try FileHandle(forWritingTo: fileURL) {
                opened.seekToEndOfFile()
                fileHandle = opened
                
                return fileHandle
            } else {
                print("Could not open log file 1")
                
                return nil
            }
        } catch let error as NSError {
            print("\(error)")
            
            return nil
        }
    }

    private func createFolder(_ path: URL) {
        if FileManager.default().fileExists(atPath: path.path!) {
            return
        }
        
        do {
            try FileManager.default().createDirectory(at: path, withIntermediateDirectories: true)
        } catch let error as NSError {
            print("Create logs folder error \(error)")
        }
    }
    
    private func makeSureFileExists(_ atURL: URL) {
        if FileManager.default().fileExists(atPath: atURL.path!) {
            return
        }
        
        try! Data().write(to: atURL, options: [])
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH-mm"
        return formatter
    }()
}
