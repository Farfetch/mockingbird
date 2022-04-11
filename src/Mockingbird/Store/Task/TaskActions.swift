//
// Copyright (c) 2020, Farfetch.
// All rights reserved.
//
// This source code is licensed under the MIT-style license found in the
// LICENSE file in the root directory of this source tree.
//

import ReSwift

enum TaskAction: Action {

    case initialize
    case startAll
    case stopAll(forceSync: Bool)
    case startProxy(isWifi: Bool)
    case stopProxy
    case startMitm
    case stopMitm
    case updateIpInfo(info: String)
}
