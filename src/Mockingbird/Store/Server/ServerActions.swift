//
// Copyright (c) 2020, Farfetch.
// All rights reserved.
//
// This source code is licensed under the MIT-style license found in the
// LICENSE file in the root directory of this source tree.
//

import ReSwift

enum ServerAction: Action {

    case initialize
    case start
    case stop
    case setCurrent(capture: ServerCapture?)
    case addCapture(capture: ServerCapture)
    case clearCapture
    case updateStats(pattern: String, stat: Float)
    case clearStats
    case saveFiles(shouldPopupFolder: Bool)
    case setContext(context: ServerContextInfo?, index: Int)
    case select(selected: Bool)
    case saveCurrentToClipboard
    case saveRecord
    case clearRefresh
}
