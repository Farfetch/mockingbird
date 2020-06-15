//
// Copyright (c) 2020, Farfetch.
// All rights reserved.
//
// This source code is licensed under the MIT-style license found in the
// LICENSE file in the root directory of this source tree.
//

import Foundation

struct RecordInfo {

    let id: String = UUID().uuidString

    var file: RecordFile
    let filePath: String
    var count: Int = 0
    var active: Bool = true
}
