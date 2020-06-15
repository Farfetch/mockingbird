//
// Copyright (c) 2020, Farfetch.
// All rights reserved.
//
// This source code is licensed under the MIT-style license found in the
// LICENSE file in the root directory of this source tree.
//

import Foundation

struct DataInfo {

    let id: String = UUID().uuidString

    var file: DataFile
    let filePath: String
    var selected: Bool = false
    var count: Int = 0
}
