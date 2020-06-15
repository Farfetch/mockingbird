//
// Copyright (c) 2020, Farfetch.
// All rights reserved.
//
// This source code is licensed under the MIT-style license found in the
// LICENSE file in the root directory of this source tree.
//

import Foundation
import Files
@testable import Mockingbird

final class DataHelper {

    enum Constant {

        static let dataType = "data"
        static let testType = "test"
        static let recordType = "record"
    }

    static func prepareData() {

        Self.prepare(for: Constant.dataType)
    }

    static func prepareTest() {

        Self.prepare(for: Constant.testType)
    }

    static func prepareRecord() {

        Self.prepare(for: Constant.recordType)
    }

    static func prepareServer() {

        if let resourcePath = Self.getResourcePath() {

            Default.Folder.main = resourcePath
        }
    }

    static func prepareAll() {

        Self.prepareData()
        Self.prepareTest()
        Self.prepareRecord()
    }
}

private extension DataHelper {

    static func getResourcePath() -> String? {

        return Bundle(for: DataHelper.self).resourcePath
    }

    static func prepare(for type: String) {

        guard let resourcePath = Self.getResourcePath() else {

            return
        }

        do {

            let originFolder = try Folder(path: resourcePath)

            var shouldCreate = false

            if !originFolder.containsSubfolder(named: type) {

                shouldCreate = true

            } else if let folder = try? originFolder.subfolder(named: type),
                folder.files.count() <= 0 {

                shouldCreate = true
            }

            if shouldCreate {

                var targetPath = "\(resourcePath)/\(type)"

                if type == Constant.recordType {

                    targetPath += "/temp"
                }

                try FileManager.default.createDirectory(atPath: targetPath, withIntermediateDirectories: true, attributes: nil)

                let targetFolder = try Folder(path: targetPath)

                for file in originFolder.files where file.name.contains(type) {

                    _ = try? file.copy(to: targetFolder)
                }
            }

            Default.Folder.main = resourcePath

        } catch {

            _log(type: .error, log: error.localizedDescription)
        }
    }
}
