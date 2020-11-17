//
// Copyright (c) 2020, Farfetch.
// All rights reserved.
//
// This source code is licensed under the MIT-style license found in the
// LICENSE file in the root directory of this source tree.
//

import Foundation

final class ProcessManager {

    static let shared = ProcessManager()

    private var mitmProcess: Process?

    func execute(process: ProcessType) {

        switch process {

        case .mitmOn:

            ProcessTask.runAsync(process: process, callback: self)

        case .ipInfo:

            ProcessTask.launchSync(process: process, callback: self)

        default:

            ProcessTask.launchAsync(process: process, callback: self)
        }
    }
}

extension ProcessManager: ProcessTaskCallback {

    func processStarted(_ process: ProcessType) {

        _log(type: .debug, log: "started: \(process)")
    }

    func stdoutUpdated(_ process: ProcessType, text: String) {

        _log(type: .debug, log: "stdout: \(text)")

        switch process {

        case .mitmOn:
            AppStore.server.dispatch(ServerAction.processed)

        case .ipInfo:
            AppStore.task.dispatch(TaskAction.updateIpInfo(info: text))

        default:
            break
        }
    }

    func stderrUpdated(_ process: ProcessType, text: String) {

        _log(type: .info, log: "stderr: \(text)")
    }

    func processError(_ process: ProcessType, error: Error) {

        _log(type: .info, log: "error: \(error)")
    }

    func processEnded(_ process: ProcessType) {

        _log(type: .debug, log: "ended: \(process)")

        switch process {

        case .mitmOn:
            AppStore.task.dispatch(TaskAction.stopMitm)

        case .mitmOff:
            AppStore.server.dispatch(ServerAction.processed)

        default:
            break
        }
    }
}
