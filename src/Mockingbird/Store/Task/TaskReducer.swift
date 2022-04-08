//
// Copyright (c) 2020, Farfetch.
// All rights reserved.
//
// This source code is licensed under the MIT-style license found in the
// LICENSE file in the root directory of this source tree.
//

import Foundation
import ReSwift
import Zip
import Files

class TaskReducer {

    static func reduce(_ action: Action, state: TaskState?) -> TaskState {

        var state = state ?? TaskState()

        guard let action = action as? TaskAction else {
            return state
        }

        switch action {

        case .initialize:

            Self.initialize()

        case .startAll:

            Self.startAll(with: &state)

        case .stopAll(let forceSync):

            Self.stopAll(with: &state, forceSync: forceSync)

        case .startProxy(let isWifi):

            Self.startProxy(with: &state, isWifi: isWifi)

        case .stopProxy:

            Self.stopProxy(with: &state)

        case .startMitm:

            Self.startMitm(with: &state)

        case .stopMitm:

            Self.stopMitm(with: &state)

        case .updateIpInfo(let info):

            state.ipInfo = info
        }

        return state
    }
}

private extension TaskReducer {

    static func initialize() {

        do {

            try FileManager.default.createDirectory(atPath: Default.Folder.mitm, withIntermediateDirectories: true, attributes: nil)

            let dataFolder = try Folder(path: Default.Folder.mitm)

            if dataFolder.files.count() <= 0 {

                if let fileURL = Bundle.main.url(forResource: "mitmdump_mb", withExtension: "zip"),
                    let destURL = URL(string: Default.Folder.mitm) {

                    try Zip.unzipFile(fileURL, destination: destURL, overwrite: false, password: nil)
                }
            }

        } catch {

            _log(type: .error, log: error.localizedDescription)
        }
    }

    static func startAll(with state: inout TaskState) {

        Self.startMitm(with: &state)
        Self.startProxy(with: &state)
    }

    static func stopAll(with state: inout TaskState, forceSync: Bool = false) {

        Self.stopProxy(with: &state, forceSync: forceSync)
        Self.stopMitm(with: &state, forceSync: forceSync)
    }

    static func startProxy(with state: inout TaskState, isWifi: Bool = false) {

        state.isProxyEnabled = true
        state.isProxyWifi = isWifi

        ProcessManager.shared.execute(process: isWifi ? .proxyWifiOn : .proxyOn)
        ProcessManager.shared.execute(process: .ipInfo)
    }

    static func stopProxy(with state: inout TaskState, forceSync: Bool = false) {

        state.isProxyEnabled = false
        state.ipInfo = ""

        ProcessManager.shared.execute(process: .proxyOff, forceSync: forceSync)
    }

    static func startMitm(with state: inout TaskState) {

        state.isMitmEnabled = true

        ProcessManager.shared.execute(process: .mitmOn(currentContext: ContextManager.shared.currentContext))
    }

    static func stopMitm(with state: inout TaskState, forceSync: Bool = false) {

        state.isMitmEnabled = false

        ProcessManager.shared.execute(process: .mitmOff, forceSync: forceSync)
    }
}
