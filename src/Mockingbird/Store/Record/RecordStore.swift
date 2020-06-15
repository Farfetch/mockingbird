//
// Copyright (c) 2020, Farfetch.
// All rights reserved.
//
// This source code is licensed under the MIT-style license found in the
// LICENSE file in the root directory of this source tree.
//

import Foundation
import ReSwift

typealias RecordStore = Store<RecordState>

struct RecordState: StateType {

    var currentRecord: RecordGroupInfo?
    var records: [RecordGroupInfo] = []

    // UI states
    var isReplayAndPop: Bool = false
}
