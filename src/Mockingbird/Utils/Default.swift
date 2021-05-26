//
// Copyright (c) 2020, Farfetch.
// All rights reserved.
//
// This source code is licensed under the MIT-style license found in the
// LICENSE file in the root directory of this source tree.
//

import Foundation
import Files

final class Default {

    public enum Token {

        static let tracking = ""
    }

    public enum Server {

        static let port = 5000
        static let path = "/api/stream"
    }

    public enum Folder {

        static var main = "/Users/" + NSUserName() + "/.mockingbird"
        static var mitm: String { main + "/mitmproxy" }
        static var capture: String { workingDirectory + "/capture" }
        static var record: String { workingDirectory + "/record" }
        static var data: String { workingDirectory + "/data" }
        static var test: String { workingDirectory + "/test" }

        static var workingDirectory = ""

        static var savedWorkingDirectory: String {

            get {

                guard let file = try? File(path: "\(Default.Folder.main)/configurations.json"),
                      let fileData = try? file.readAsString(),
                      let startRange = fileData.range(of: "=")?.upperBound else {

                    return "/Users/" + NSUserName() + "/.mockingbird"
                }

                return String(fileData.suffix(from: startRange))
            }

            set {

                if let configurationsFile = try? File(path: "\(Default.Folder.main)/configurations.json") {

                    let configurations = Configuration(dataFolder: newValue)
                    guard let writeData = try? configurations.jsonData() else { return }

                    try? configurationsFile.write(writeData)

                } else {

                    guard let mainFolder = try? Files.Folder(path: Default.Folder.main),
                          let configurationsFolderFile = try? mainFolder.createFile(named: "configurations.json") else {

                        return
                    }

                    let configurations = Configuration(dataFolder: newValue)
                    guard let writeData = try? configurations.jsonData() else { return }

                    try? configurationsFolderFile.write(writeData)
                }
            }
        }
    }
}
