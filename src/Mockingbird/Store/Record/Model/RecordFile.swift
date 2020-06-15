//
// Copyright (c) 2020, Farfetch.
// All rights reserved.
//
// This source code is licensed under the MIT-style license found in the
// LICENSE file in the root directory of this source tree.
//

import Foundation

struct RecordFile: Codable {

    let type: String
    let code: Int
    let url: String
    var payload: String
}
