//
// Copyright (c) 2020, Farfetch.
// All rights reserved.
//
// This source code is licensed under the MIT-style license found in the
// LICENSE file in the root directory of this source tree.
//

import Foundation

struct ServerStatistic {

    let pattern: String
    var count: Int = 1
    var bytes: Int = 0
    var bytesString: String = ""

    public mutating func update(bytes: Int) {

        self.count += 1
        self.bytes += bytes
        self.bytesString = ByteCountFormatter.string(fromByteCount: Int64(self.bytes), countStyle: .file)
    }
}
