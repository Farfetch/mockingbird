//
// Copyright (c) 2020, Farfetch.
// All rights reserved.
//
// This source code is licensed under the MIT-style license found in the
// LICENSE file in the root directory of this source tree.
//

import ReSwift

enum DataAction: Action {

    case initialize
    case clearItems
    case setCurrent(data: DataInfo?)
    case updateDataPayload(payload: String)
    case updateStats(id: String)
    case clearStats
    case select(id: String, selected: Bool)
    case selectWithPath(path: String)
    case unselectAll
    case setDetailedInfo
}
