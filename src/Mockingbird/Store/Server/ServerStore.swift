//
// Copyright (c) 2020, Farfetch.
// All rights reserved.
//
// This source code is licensed under the MIT-style license found in the
// LICENSE file in the root directory of this source tree.
//

import Foundation
import ReSwift

typealias ServerStore = Store<ServerState>

struct ServerState: StateType {

    var currentCapture: ServerCapture?
    var captures: [ServerCapture] = []

    var stats: [ServerStatistic] = []
    var statsHistory: [Float] = []

    var currentContext: ServerContextInfo?
    var currentContextIndex: Int = 0
    var contextTitles: [String] = []

    var filter: String = ""

    var isRunning: Bool = false
    var isProcessingCommand: Bool = false

    // UI states
    var isRequestSelected: Bool = true
    var refreshView: Bool = false
}
