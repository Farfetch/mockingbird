//
// Copyright (c) 2020, Farfetch.
// All rights reserved.
//
// This source code is licensed under the MIT-style license found in the
// LICENSE file in the root directory of this source tree.
//

import Foundation
import ReSwift

typealias DataStore = Store<DataState>

struct DataState: StateType {

    var currentData: DataInfo?
    var datas: [DataInfo] = []

    // UI states
    var totalSelection: Int = 0
    var detailedInfo: Bool = false
}
