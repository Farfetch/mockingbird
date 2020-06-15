//
// Copyright (c) 2020, Farfetch.
// All rights reserved.
//
// This source code is licensed under the MIT-style license found in the
// LICENSE file in the root directory of this source tree.
//

import Foundation

struct RecordGroupInfo {

    let id: String = UUID().uuidString

    let name: String
    var items: [RecordInfo]
    var selected: Bool = false
}
