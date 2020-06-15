//
// Copyright (c) 2020, Farfetch.
// All rights reserved.
//
// This source code is licensed under the MIT-style license found in the
// LICENSE file in the root directory of this source tree.
//

import ReSwift

enum RecordAction: Action {

    case initialize
    case setCurrent(record: RecordGroupInfo?)
    case updateStats(id: String)
    case updateActive(id: String, active: Bool)
    case refreshSelected
    case clearStats
    case select(id: String, selected: Bool)
    case selectReplayAndPop
    case unselectAll
}
