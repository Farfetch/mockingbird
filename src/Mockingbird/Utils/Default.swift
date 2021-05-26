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
        static var capture: String { main + "/capture" }
        static var record: String { main + "/record" }
        static var data: String { mockedDataDirectory + "/data" }
        static var test: String { mockedDataDirectory + "/test" }

        static var mockedDataDirectory: String {

            get {

                guard let file = try? File(path: "\(Default.Folder.main)/dataFolder.json"),
                      let fileData = try? file.readAsString(),
                      let startRange = fileData.range(of: "=")?.upperBound else {

                    return "/Users/" + NSUserName() + "/.mockingbird"
                }

                return String(fileData.suffix(from: startRange))
            }

            set {

                if let file = try? File(path: "\(Default.Folder.main)/dataFolder.json") {

                    let writeData = "dataFolder="+newValue

                    try? file.write(writeData)

                } else {

                    guard let mainFolder = try? Files.Folder(path: Default.Folder.main),
                          let dataFolderFile = try? mainFolder.createFile(named: "dataFolder") else {

                        return
                    }

                    let writeData = "dataFolder="+newValue

                    try? dataFolderFile.write(writeData)
                }
            }
        }
    }
}
