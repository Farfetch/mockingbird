//
// Copyright (c) 2020, Farfetch.
// All rights reserved.
//
// This source code is licensed under the MIT-style license found in the
// LICENSE file in the root directory of this source tree.
//

import Foundation
import ReSwift

typealias TaskStore = Store<TaskState>

struct TaskState: StateType {

    var ipInfo: String = ""
    var isMitmEnabled: Bool = false
    var isProxyEnabled: Bool = false
    var isProxyWifi: Bool = false
}
